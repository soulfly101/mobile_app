class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String content;
  final DateTime lastEdited;
  final bool isPinned;

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? lastEdited,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      lastEdited: lastEdited ?? this.lastEdited,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'content': content,
        'lastEdited': lastEdited.toIso8601String(),
        'isPinned': isPinned,
      };

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      lastEdited: DateTime.parse(json['lastEdited'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}
