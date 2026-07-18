import '../entities/note_entity.dart';

abstract class NoteRepository {
  Future<List<NoteEntity>> getNotes();

  Future<NoteEntity> getNoteDetail(int id);

  Future<int> saveNote({
    required int noteId,
    required int folderId,
    required String title,
  });

  Future<void> saveContent({
    required int noteId,
    required String title,
    required List<Map<String, dynamic>> content,
  });

  Future<int> uploadAttachment({
    required int noteId,
    required String filePath,
    required String fileName,
    required String blockId,
    required int displayOrder,
  });

  Future<void> updateState({
    required int noteId,
    required bool isPinned,
    required bool isArchived,
    required bool isLocked,
  });
}