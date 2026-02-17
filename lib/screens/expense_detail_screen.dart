import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/expense_database.dart';
import '../models/category.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ExpenseDatabase.instance.deleteExpense(expense.id!);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _edit(BuildContext context) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense)),
    );
    if (changed == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('MMMM dd, yyyy').format(expense.date);
    final icon =
        ExpenseCategory.categoryIcons[expense.category] ?? Icons.category;

    return Scaffold(
      appBar: AppBar(
        title: Text(expense.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Amount', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      'GHS ${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(
                      Icons.category,
                      'Category',
                      expense.category,
                      trailingIcon: icon,
                    ),
                    const Divider(),
                    _row(Icons.calendar_today, 'Date', dateText),
                    if (expense.notes != null &&
                        expense.notes!.trim().isNotEmpty) ...[
                      const Divider(),
                      _row(Icons.note, 'Notes', expense.notes!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value, {
    IconData? trailingIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: trailingIcon == null
                ? Text(value)
                : Row(
                    children: [
                      Icon(trailingIcon, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(value)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
