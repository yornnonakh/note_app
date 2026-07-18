import '../../domain/entities/folder_entity.dart';

class FolderModel extends FolderEntity {
  const FolderModel({
    required super.id,
    required super.name,
    required super.iconName,
    required super.colorValue,
    required super.sortOrder,
  });

  factory FolderModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return FolderModel(
      id: _toInt(
        json['id'] ?? json['folderId'],
      ),
      name: json['name']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      colorValue:
      json['colorValue']?.toString() ?? '',
      sortOrder: _toInt(json['sortOrder']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}