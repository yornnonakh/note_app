import 'dart:convert';

import '../../domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    required super.id,
    required super.folderId,
    required super.title,
    required super.content,
    required super.isPinned,
    required super.isArchived,
    required super.isLocked,
  });

  factory NoteModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NoteModel(
      id: _toInt(
        json['id'] ?? json['noteId'],
      ),
      folderId: _toInt(json['folderId']),
      title: json['title']?.toString() ?? '',
      content: _parseContent(json['content']),
      isPinned: _toBool(json['isPinned']),
      isArchived: _toBool(json['isArchived']),
      isLocked: _toBool(json['isLocked']),
    );
  }

  static List<Map<String, dynamic>> _parseContent(
      dynamic value,
      ) {
    dynamic decodedValue = value;

    if (value is String && value.trim().isNotEmpty) {
      try {
        decodedValue = jsonDecode(value);
      } catch (_) {
        return <Map<String, dynamic>>[];
      }
    }

    if (decodedValue is! List) {
      return <Map<String, dynamic>>[];
    }

    return decodedValue
        .whereType<Map>()
        .map(
          (Map item) => Map<String, dynamic>.from(item),
    )
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final String normalized =
        value?.toString().toLowerCase() ?? '';

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }
}