import 'package:flutter/material.dart';
import '../database/expense_database.dart';
import '../models/expense.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Expense> _expenses = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);

    final list = await ExpenseDatabase.instance.getAllExpenses();
    double total = 0;
    for (final e in list) {
      total += e.amount;
    }

    setState(() {
      _expenses = list;
      _total = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'GHS ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _expenses.isEmpty
                      ? const Center(child: Text('No expenses yet. Tap + to add.'))
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            itemCount: _expenses.length,
                            itemBuilder: (context, index) {
                              final expense = _expenses[index];
                              return ExpenseCard(
                                expense: expense,
                                onTap: () async {
                                  final changed = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExpenseDetailScreen(expense: expense),
                                    ),
                                  );
                                  if (changed == true) _refresh();
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
          if (added == true) _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
