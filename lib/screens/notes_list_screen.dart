import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/notes_service.dart';
import '../services/theme_service.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService.instance;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isExporting = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    await _notesService.loadNotes();
    if (!mounted) {
      return;
    }

    setState(() => _isLoading = false);
  }

  void _handleSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
  }

  Future<void> _openEditor([Note? note]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );

    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete note'),
          content: const Text('This will permanently remove the encrypted note.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _notesService.deleteNote(id);
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _togglePinned(String id) async {
    await _notesService.togglePinned(id);
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _toggleTheme() async {
    await ThemeService.instance.toggleTheme();
    if (!mounted) {
      return;
    }

    final isDark = ThemeService.instance.themeMode.value == ThemeMode.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isDark ? 'Dark mode enabled.' : 'Light mode enabled.')),
    );
  }

  Future<void> _exportNotes() async {
    setState(() => _isExporting = true);
    final exportPath = await _notesService.exportNotes();
    if (!mounted) {
      return;
    }

    setState(() => _isExporting = false);

    if (exportPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No notes available to export.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Encrypted export saved to $exportPath')),
    );
  }

  String _formatDate(DateTime date) {
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} ${date.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notesService.search(_searchQuery);
    final isDark = ThemeService.instance.themeMode.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Notes'),
        actions: <Widget>[
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: _toggleTheme,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(
            tooltip: 'Export encrypted notes',
            onPressed: _isExporting ? null : _exportNotes,
            icon: _isExporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by title or content',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Text(
                    '${notes.length} note${notes.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  const Text('Pinned notes stay on top'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notes.isEmpty
                      ? const _EmptyState()
                      : ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (BuildContext context, int index) {
                            final note = notes[index];
                            return Column(
                              children: <Widget>[
                                NoteCard(
                                  note: note,
                                  onTap: () => _openEditor(note),
                                  onDelete: () => _deleteNote(note.id),
                                  onTogglePinned: () => _togglePinned(note.id),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Last edited ${_formatDate(note.lastEdited)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.65),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first encrypted note, then pin important ones and search them instantly.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
