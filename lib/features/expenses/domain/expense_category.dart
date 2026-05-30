import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final bool isDefault;
}

class DefaultExpenseCategories {
  static const food = ExpenseCategory(
    id: 'food',
    name: 'Food',
    color: Color(0xFF6D5EF6),
    icon: Icons.restaurant_rounded,
    isDefault: true,
  );
  static const transport = ExpenseCategory(
    id: 'transport',
    name: 'Transport',
    color: Color(0xFF00BFA6),
    icon: Icons.directions_car_rounded,
    isDefault: true,
  );
  static const shopping = ExpenseCategory(
    id: 'shopping',
    name: 'Shopping',
    color: Color(0xFFFFB020),
    icon: Icons.shopping_bag_rounded,
    isDefault: true,
  );
  static const bills = ExpenseCategory(
    id: 'bills',
    name: 'Bills',
    color: Color(0xFFFF5A65),
    icon: Icons.receipt_long_rounded,
    isDefault: true,
  );
  static const entertainment = ExpenseCategory(
    id: 'entertainment',
    name: 'Entertainment',
    color: Color(0xFF8D6BFF),
    icon: Icons.movie_rounded,
    isDefault: true,
  );
  static const healthcare = ExpenseCategory(
    id: 'healthcare',
    name: 'Healthcare',
    color: Color(0xFF3A86FF),
    icon: Icons.local_hospital_rounded,
    isDefault: true,
  );
  static const education = ExpenseCategory(
    id: 'education',
    name: 'Education',
    color: Color(0xFF5BD6FF),
    icon: Icons.school_rounded,
    isDefault: true,
  );
  static const travel = ExpenseCategory(
    id: 'travel',
    name: 'Travel',
    color: Color(0xFF00D17D),
    icon: Icons.flight_takeoff_rounded,
    isDefault: true,
  );
  static const investment = ExpenseCategory(
    id: 'investment',
    name: 'Investment',
    color: Color(0xFF2EC4B6),
    icon: Icons.trending_up_rounded,
    isDefault: true,
  );
  static const other = ExpenseCategory(
    id: 'other',
    name: 'Other',
    color: Color(0xFF9AA4B2),
    icon: Icons.category_rounded,
    isDefault: true,
  );

  static const all = <ExpenseCategory>[
    food,
    transport,
    shopping,
    bills,
    entertainment,
    healthcare,
    education,
    travel,
    investment,
    other,
  ];

  static ExpenseCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => other);
}

