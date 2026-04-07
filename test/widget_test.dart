import 'package:flutter_test/flutter_test.dart';
import 'package:week10_11/models/note.dart';

void main() {
  test('note serializes pinned state correctly', () {
    final note = Note(
      id: '1',
      title: 'Secure',
      content: 'Encrypted content',
      lastEdited: DateTime.parse('2026-04-07T18:00:00Z'),
      isPinned: true,
    );

    final decoded = Note.fromJson(note.toJson());

    expect(decoded.id, '1');
    expect(decoded.title, 'Secure');
    expect(decoded.isPinned, isTrue);
  });
}
