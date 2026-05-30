import 'package:expense_tracker/core/formatters/money_format.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/domain/expense_category.dart';
import 'package:expense_tracker/features/expenses/presentation/expenses_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  const ExpenseFormSheet({super.key, this.initial});

  final Expense? initial;

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late DateTime _date;
  late String _categoryId;
  String? _receiptPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _amount = TextEditingController(
      text: initial == null ? '' : initial.amount.toStringAsFixed(2),
    );
    _notes = TextEditingController(text: initial?.notes ?? '');
    _date = initial?.dateTime ?? DateTime.now();
    _categoryId = initial?.categoryId ?? DefaultExpenseCategories.food.id;
    _receiptPath = initial?.receiptImagePath;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (file == null) return;
    setState(() => _receiptPath = file.path);
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted) return;
    if (selected == null) return;
    setState(() => _date = DateTime(selected.year, selected.month, selected.day));
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final parsedAmount = double.tryParse(_amount.text.trim());

    if (title.isEmpty || parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title and a valid amount.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final repo = ref.read(expenseRepositoryProvider);
      final initial = widget.initial;
      final expense = (initial == null)
          ? Expense(
              id: const Uuid().v4(),
              title: title,
              amount: parsedAmount,
              categoryId: _categoryId,
              dateTime: _date,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              receiptImagePath: _receiptPath,
              createdAt: now,
              updatedAt: now,
            )
          : initial.copyWith(
              title: title,
              amount: parsedAmount,
              categoryId: _categoryId,
              dateTime: _date,
              notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
              receiptImagePath: _receiptPath,
              updatedAt: now,
            );

      await repo.upsert(expense);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final initial = widget.initial;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    initial == null ? 'Add expense' : 'Edit expense',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Lunch, Taxi, Internet',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (Birr)',
                  hintText: formatBirr(0).replaceAll(RegExp(r'[\d,.\s]+'), ''),
                  prefixText: 'Br ',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                items: [
                  for (final c in DefaultExpenseCategories.all)
                    DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                ],
                onChanged: _saving ? null : (v) => setState(() => _categoryId = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(
                        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _pickReceipt,
                      icon: const Icon(Icons.image_rounded),
                      label: Text(_receiptPath == null ? 'Receipt' : 'Receipt ✓'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Reason, details, etc.',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _saving
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Text(initial == null ? 'Add expense' : 'Save changes'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

