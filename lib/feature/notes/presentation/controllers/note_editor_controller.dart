import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';

class NoteEditorController extends GetxController {
  final NoteRepository noteRepository;

  NoteEditorController({
    required this.noteRepository,
  });

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController textController =
  TextEditingController();

  final RxList<Map<String, dynamic>> blocks =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final Uuid _uuid = const Uuid();

  late final int noteId;

  @override
  void onInit() {
    super.onInit();

    final dynamic argument = Get.arguments;

    if (argument is! int) {
      errorMessage.value = 'Invalid note ID.';
      return;
    }

    noteId = argument;
    loadNote();
  }

  Future<void> loadNote() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final NoteEntity note =
      await noteRepository.getNoteDetail(noteId);

      titleController.text = note.title;
      blocks.assignAll(note.content);

      final Map<String, dynamic>? textBlock =
      _firstTextBlock();

      textController.text =
          textBlock?['text']?.toString() ?? '';
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveNote() async {
    try {
      isSaving.value = true;

      final String title =
      titleController.text.trim();

      final String text =
      textController.text.trim();

      final Map<String, dynamic>? currentTextBlock =
      _firstTextBlock();

      final String textBlockId =
          currentTextBlock?['id']?.toString() ??
              _uuid.v4();

      final List<Map<String, dynamic>>
      updatedBlocks = blocks
          .where(
            (Map<String, dynamic> item) =>
        item['type'] != 'text',
      )
          .toList();

      if (text.isNotEmpty) {
        updatedBlocks.insert(0, {
          'id': textBlockId,
          'type': 'text',
          'text': text,
        });
      }

      blocks.assignAll(updatedBlocks);

      await noteRepository.saveContent(
        noteId: noteId,
        title: title,
        content: blocks.toList(),
      );

      Get.snackbar(
        'Saved',
        'Your note was saved successfully.',
      );
    } catch (error) {
      Get.snackbar(
        'Save failed',
        error.toString(),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> uploadAttachment() async {
    try {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final PlatformFile file = result.files.single;

      if (file.path == null) {
        Get.snackbar(
          'File error',
          'The selected file does not have a path.',
        );
        return;
      }

      isSaving.value = true;

      final String blockId = _uuid.v4();

      final int attachmentId =
      await noteRepository.uploadAttachment(
        noteId: noteId,
        filePath: file.path!,
        fileName: file.name,
        blockId: blockId,
        displayOrder: blocks.length + 1,
      );

      blocks.add({
        'id': blockId,
        'type': 'attachment',
        'attachmentId': attachmentId,
        'displayName': file.name,
      });

      await noteRepository.saveContent(
        noteId: noteId,
        title: titleController.text.trim(),
        content: blocks.toList(),
      );

      Get.snackbar(
        'Uploaded',
        '${file.name} was uploaded.',
      );
    } catch (error) {
      Get.snackbar(
        'Upload failed',
        error.toString(),
      );
    } finally {
      isSaving.value = false;
    }
  }

  void removeAttachment(
      Map<String, dynamic> block,
      ) {
    blocks.remove(block);
  }

  Map<String, dynamic>? _firstTextBlock() {
    for (final Map<String, dynamic> block
    in blocks) {
      if (block['type'] == 'text') {
        return block;
      }
    }

    return null;
  }

  @override
  void onClose() {
    titleController.dispose();
    textController.dispose();
    super.onClose();
  }
}