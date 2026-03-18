import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isComplete ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${task.courseCode}\nDue: ${DateFormat('dd/MM/yyyy').format(task.dueDate)}',
        ),
        isThreeLine: true,
        trailing: Checkbox(
          value: task.isComplete,
          onChanged: onChanged,
        ),
      ),
    );
  }
}