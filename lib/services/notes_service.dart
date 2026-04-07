import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/note.dart';
import '../utils/encryption_helper.dart';
import 'secure_storage_service.dart';

class NotesService {
  NotesService._();

  static final NotesService instance = NotesService._();

  List<Note> _notes = const <Note>[];

  List<Note> get notes => List<Note>.unmodifiable(_notes);

  Future<void> loadNotes() async {
    final encryptedJson = await SecureStorageService.loadNotes();
    final encryptionKey = await SecureStorageService.loadEncryptionKey();

    if (encryptedJson == null || encryptionKey == null) {
      _notes = const <Note>[];
      return;
    }

    try {
      final decryptedJson = EncryptionHelper.decrypt(
        cipherText: encryptedJson,
        secret: encryptionKey,
      );
      final decoded = jsonDecode(decryptedJson) as List<dynamic>;
      _notes = decoded
          .map((dynamic item) => Note.fromJson(item as Map<String, dynamic>))
          .toList();
      _sortNotes();
    } catch (_) {
      _notes = const <Note>[];
    }
  }

  Future<void> addNote(Note note) async {
    _notes = <Note>[note, ..._notes];
    _sortNotes();
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((Note item) => item.id == note.id);
    if (index == -1) {
      return;
    }

    final updated = List<Note>.from(_notes);
    updated[index] = note;
    _notes = updated;
    _sortNotes();
    await _saveNotes();
  }

  Future<void> deleteNote(String id) async {
    _notes = _notes.where((Note note) => note.id != id).toList();
    await _saveNotes();
  }

  Future<void> togglePinned(String id) async {
    _notes = _notes
        .map(
          (Note note) => note.id == id
              ? note.copyWith(
                  isPinned: !note.isPinned,
                  lastEdited: DateTime.now(),
                )
              : note,
        )
        .toList();
    _sortNotes();
    await _saveNotes();
  }

  List<Note> search(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return notes;
    }

    return _notes.where((Note note) {
      return note.title.toLowerCase().contains(normalized) ||
          note.content.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }

  Future<String?> exportNotes() async {
    final encryptionKey = await SecureStorageService.loadEncryptionKey();
    if (encryptionKey == null || _notes.isEmpty) {
      return null;
    }

    final exportPayload = jsonEncode(<String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'noteCount': _notes.length,
      'notes': _notes.map((Note note) => note.toJson()).toList(growable: false),
    });

    final encrypted = EncryptionHelper.encrypt(
      plainText: exportPayload,
      secret: encryptionKey,
    );

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      '${directory.path}${Platform.pathSeparator}secure_notes_export_$timestamp.json',
    );
    await file.writeAsString(encrypted);
    return file.path;
  }

  Future<void> _saveNotes() async {
    final encryptionKey = await SecureStorageService.loadEncryptionKey();
    if (encryptionKey == null) {
      return;
    }

    final jsonString = jsonEncode(
      _notes.map((Note note) => note.toJson()).toList(growable: false),
    );
    final encrypted = EncryptionHelper.encrypt(
      plainText: jsonString,
      secret: encryptionKey,
    );
    await SecureStorageService.saveNotes(encrypted);
  }

  void _sortNotes() {
    _notes = List<Note>.from(_notes)
      ..sort((Note a, Note b) {
        if (a.isPinned != b.isPinned) {
          return a.isPinned ? -1 : 1;
        }
        return b.lastEdited.compareTo(a.lastEdited);
      });
  }
}
