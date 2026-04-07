import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePinned,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePinned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = note.content.trim().isEmpty
        ? 'No additional content'
        : note.content.trim().replaceAll('\n', ' ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leading: Icon(
          note.isPinned ? Icons.push_pin : Icons.note_outlined,
          color: note.isPinned ? theme.colorScheme.primary : null,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'pin') {
              onTogglePinned();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'pin',
              child: Text(note.isPinned ? 'Unpin note' : 'Pin note'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete note'),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
