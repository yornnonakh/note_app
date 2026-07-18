import 'package:flutter/cupertino.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_parser.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/notes_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final ApiClient apiClient;

  const NoteRepositoryImpl({
    required this.apiClient,
  });

  @override
  Future<List<NoteEntity>> getNotes() async {
    final dynamic response = await apiClient.get(
      ApiEndpoints.notes,
    );

    debugPrint('NOTE API RESPONSE: $response');

    final List<Map<String, dynamic>> items =
    ApiParser.asList(response);

    return items
        .map(NoteModel.fromJson)
        .toList();
  }

  @override
  Future<NoteEntity> getNoteDetail(int id) async {
    final dynamic response = await apiClient.get(
      ApiEndpoints.noteDetail(id),
    );
    final Map<String, dynamic> data =
    ApiParser.asMap(response);
    return NoteModel.fromJson(data);
  }

  @override
  Future<int> saveNote({
    required int noteId,
    required int folderId,
    required String title,
  }) async {
    final dynamic response = await apiClient.post(
      ApiEndpoints.saveNote,
      body: {
        'noteId': noteId,
        'folderId': folderId,
        'title': title,
      },
    );

    return ApiParser.readId(
      response,
      keys: const ['noteId', 'id'],
    );
  }

  @override
  Future<void> saveContent({
    required int noteId,
    required String title,
    required List<Map<String, dynamic>> content,
  }) async {
    await apiClient.post(
      ApiEndpoints.saveNoteContent,
      body: {
        'id': noteId,
        'title': title,
        'content': content,
      },
    );
  }

  @override
  Future<int> uploadAttachment({
    required int noteId,
    required String filePath,
    required String fileName,
    required String blockId,
    required int displayOrder,
  }) async {
    final dynamic response = await apiClient.uploadFile(
      ApiEndpoints.uploadAttachment,
      filePath: filePath,
      fileName: fileName,
      fields: {
        'Id': noteId,
        'BlockId': blockId,
        'DisplayOrder': displayOrder,
      },
    );

    return ApiParser.readId(
      response,
      keys: const ['attachmentId', 'id'],
    );
  }

  @override
  Future<void> updateState({
    required int noteId,
    required bool isPinned,
    required bool isArchived,
    required bool isLocked,
  }) async {
    await apiClient.post(
      ApiEndpoints.updateNoteState,
      body: {
        'id': noteId,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'isLocked': isLocked,
      },
    );
  }
}