import 'package:flutter/cupertino.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_parser.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/repositories/folder_repository_impl.dart';
import '../models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  final ApiClient apiClient;

  const FolderRepositoryImpl({
    required this.apiClient,
  });

  @override
  Future<List<FolderEntity>> getFolders() async {
    final dynamic response = await apiClient.get(
      ApiEndpoints.folders,
    );

    debugPrint('FOLDER API RESPONSE: $response');

    final List<Map<String, dynamic>> items =
    ApiParser.asList(response);

    return items
        .map(FolderModel.fromJson)
        .toList();
  }
  @override
  Future<void> saveFolder({
    required int id,
    required String name,
    required String iconName,
    required String colorValue,
    required int sortOrder,
  }) async {
    await apiClient.post(
      ApiEndpoints.saveFolder,
      body: {
        'id': id,
        'name': name,
        'iconName': iconName,
        'colorValue': colorValue,
        'sortOrder': sortOrder,
      },
    );
  }

  @override
  Future<void> deleteOrRestoreFolder({
    required int id,
    required bool isDelete,
  }) async {
    await apiClient.post(
      ApiEndpoints.deleteRestoreFolder,
      body: {
        'id': id,
        'isDelete': isDelete,
      },
    );
  }
}