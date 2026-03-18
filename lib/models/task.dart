class Task {
  String title;
  String courseCode;
  DateTime dueDate;
  bool isComplete;

  Task({
    required this.title,
    required this.courseCode,
    required this.dueDate,
    this.isComplete = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'courseCode': courseCode,
      'dueDate': dueDate.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      courseCode: json['courseCode'],
      dueDate: DateTime.parse(json['dueDate']),
      isComplete: json['isComplete'] ?? false,
    );
  }
}
