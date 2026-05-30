import 'package:intl/intl.dart';

final _birr = NumberFormat.currency(symbol: 'Br ', decimalDigits: 2);

String formatBirr(num value) => _birr.format(value);

