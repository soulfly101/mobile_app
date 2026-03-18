import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  List<Task> getDefaultTasks() {
    return [
      Task(
        title: 'Complete Flutter Assignment',
        courseCode: 'INFT425',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      Task(
        title: 'Study Firebase Notes',
        courseCode: 'INFT425',
        dueDate: DateTime.now().add(const Duration(days: 4)),
      ),
      Task(
        title: 'Prepare Profile Screen UI',
        courseCode: 'INFT425',
        dueDate: DateTime.now().add(const Duration(days: 6)),
      ),
    ];
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskListJson =
        tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', taskListJson);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTasks = prefs.getStringList('tasks');

    if (savedTasks != null && savedTasks.isNotEmpty) {
      setState(() {
        tasks = savedTasks
            .map((taskString) => Task.fromJson(jsonDecode(taskString)))
            .toList();
      });
    } else {
      setState(() {
        tasks = getDefaultTasks();
      });
    }
  }

  Future<void> addTaskDialog() async {
    final titleController = TextEditingController();
    final courseCodeController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: courseCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Course Code',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'No date selected'
                                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              setDialogState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    courseCodeController.text.isNotEmpty &&
                    selectedDate != null) {
                  setState(() {
                    tasks.add(
                      Task(
                        title: titleController.text,
                        courseCode: courseCodeController.text,
                        dueDate: selectedDate!,
                      ),
                    );
                  });

                  await saveTasks();

                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void toggleTask(int index, bool? value) async {
    setState(() {
      tasks[index].isComplete = value ?? false;
    });
    await saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks available'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskTile(
                  task: tasks[index],
                  onChanged: (value) => toggleTask(index, value),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}