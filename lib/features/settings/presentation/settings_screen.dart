import 'package:expense_tracker/app/theme/theme_mode_controller.dart';
import 'package:expense_tracker/features/export/pdf/pdf_report_service.dart';
import 'package:expense_tracker/features/expenses/presentation/expenses_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialRange,
    );
    if (range == null) return;

    final expenses = ref.read(expensesStreamProvider).valueOrNull ?? const [];
    final doc = const PdfReportService().buildExpenseReport(
      from: DateTime(range.start.year, range.start.month, range.start.day),
      to: DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59),
      expenses: expenses,
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: RadioGroup<ThemeMode>(
                groupValue: mode,
                onChanged: (v) {
                  if (v == null) return;
                  ref
                      .read(themeModeControllerProvider.notifier)
                      .setThemeMode(v);
                },
                child: const Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.system,
                      title: Text('System'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text('Light'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text('Dark (AMOLED)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_rounded),
            title: const Text('Export PDF report'),
            subtitle: const Text('Select a date range and generate a report'),
            onTap: () => _exportPdf(context, ref),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.picture_in_picture_alt_rounded),
            title: const Text('Dashboard background'),
            subtitle: const Text('Coming next: wallpapers, gradients, particles'),
            onTap: () {},
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.lock_rounded),
            title: const Text('Biometrics'),
            subtitle: const Text('Coming next: FaceID/TouchID unlock'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

