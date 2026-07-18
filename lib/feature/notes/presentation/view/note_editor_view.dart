import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_editor_controller.dart';

class NoteEditorView
    extends GetView<NoteEditorController> {
  const NoteEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          Obx(
                () => IconButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.uploadAttachment,
              icon: const Icon(Icons.attach_file),
            ),
          ),
          Obx(
                () => IconButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.saveNote,
              icon: controller.isSaving.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.save_outlined),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.error,
                ),
              ),
            ),
          );
        }

        final List<Map<String, dynamic>> attachments =
        controller.blocks.where(
              (Map<String, dynamic> block) {
            return block['type'] == 'attachment';
          },
        ).toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: controller.titleController,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Note title',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            TextField(
              controller: controller.textController,
              minLines: 12,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Start writing your note...',
                border: InputBorder.none,
              ),
            ),
            if (attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Attachments',
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...attachments.map(
                    (Map<String, dynamic> attachment) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.insert_drive_file_outlined,
                      ),
                      title: Text(
                        attachment['displayName']
                            ?.toString() ??
                            'Attachment',
                      ),
                      subtitle: Text(
                        'ID: ${attachment['attachmentId'] ?? ''}',
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          controller.removeAttachment(
                            attachment,
                          );
                        },
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 100),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.saveNote,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save'),
      ),
    );
  }
}