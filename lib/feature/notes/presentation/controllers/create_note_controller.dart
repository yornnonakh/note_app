import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../folders/domain/entities/folder_entity.dart';
import 'home_controller.dart';

class CreateNoteController
    extends GetxController {
  final HomeController homeController;

  CreateNoteController({
    required this.homeController,
  });

  final TextEditingController titleController =
  TextEditingController();

  final RxnInt selectedFolderId =
  RxnInt();

  final RxBool isSaving = false.obs;

  final RxString errorMessage = ''.obs;

  List<FolderEntity> get folders {
    return homeController.folders;
  }

  @override
  void onInit() {
    super.onInit();

    selectedFolderId.value =
        homeController.selectedFolderId.value ??
            (homeController.folders.isNotEmpty
                ? homeController.folders.first.id
                : null);
  }

  void selectFolder(int folderId) {
    selectedFolderId.value = folderId;
  }

  Future<void> saveNote() async {
    FocusManager.instance.primaryFocus
        ?.unfocus();

    final String title =
    titleController.text.trim();

    if (title.isEmpty) {
      errorMessage.value =
      'Please enter a note title.';
      return;
    }

    final int? folderId =
        selectedFolderId.value;

    if (folderId == null) {
      errorMessage.value =
      'Please choose a folder.';
      return;
    }

    try {
      isSaving.value = true;
      errorMessage.value = '';

      final int? noteId =
      await homeController.createNote(
        title: title,
        folderId: folderId,
        openEditor: false,
      );

      if (noteId == null) {
        return;
      }

      await Get.offNamed(
        AppRoutes.noteEditor,
        arguments: noteId,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}