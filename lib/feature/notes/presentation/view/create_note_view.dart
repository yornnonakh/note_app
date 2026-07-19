import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../folders/domain/entities/folder_entity.dart';
import '../../../main/presentation/widgets/app_liquid_background_widget.dart';
import '../controllers/create_note_controller.dart';

class CreateNoteView
    extends GetView<CreateNoteController> {
  const CreateNoteView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus
              ?.unfocus();
        },
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: AppLiquidBackgroundWidget(),
            ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      12,
                      8,
                      16,
                      8,
                    ),
                    child: Row(
                      children: <Widget>[
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: Get.back,
                          child: const Icon(
                            CupertinoIcons.back,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Create Note',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                      const EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                          const BoxConstraints(
                            maxWidth: 520,
                          ),
                          child:
                          const _CreateNoteCard(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateNoteCard
    extends GetView<CreateNoteController> {
  const _CreateNoteCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
    Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1B1D22)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(
            alpha: isDark ? 0.18 : 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colorScheme.primary
                    .withValues(alpha: 0.12),
                borderRadius:
                BorderRadius.circular(27),
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            'Note title',
            style:
            theme.textTheme.labelLarge
                ?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller:
            controller.titleController,
            autofocus: true,
            textInputAction:
            TextInputAction.done,
            onSubmitted: (_) {
              controller.saveNote();
            },
            decoration: const InputDecoration(
              hintText: 'Enter note title',
              prefixIcon: Icon(
                Icons.title_rounded,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Choose folder',
            style:
            theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
                () {
              if (controller.folders.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme
                        .errorContainer
                        .withValues(alpha: 0.55),
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'No folders available. Create a folder first.',
                  ),
                );
              }

              return Column(
                children: controller.folders.map(
                      (FolderEntity folder) {
                    final bool selected =
                        controller
                            .selectedFolderId
                            .value ==
                            folder.id;

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: _FolderSelectionTile(
                        folder: folder,
                        selected: selected,
                        onTap: () {
                          controller.selectFolder(
                            folder.id,
                          );
                        },
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
          Obx(() {
            final String error =
                controller.errorMessage.value;

            if (error.isEmpty) {
              return const SizedBox(
                height: 18,
              );
            }

            return Padding(
              padding:
              const EdgeInsets.only(
                top: 12,
              ),
              child: Text(
                error,
                style: TextStyle(
                  color: colorScheme.error,
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Obx(
                () => FilledButton.icon(
              onPressed:
              controller.isSaving.value ||
                  controller
                      .folders.isEmpty
                  ? null
                  : controller.saveNote,
              icon: controller.isSaving.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.arrow_forward_rounded,
              ),
              label: Text(
                controller.isSaving.value
                    ? 'Creating...'
                    : 'Create and Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderSelectionTile
    extends StatelessWidget {
  final FolderEntity folder;
  final bool selected;
  final VoidCallback onTap;

  const _FolderSelectionTile({
    required this.folder,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
    Theme.of(context);

    final ColorScheme colorScheme =
        theme.colorScheme;

    return Material(
      color: selected
          ? colorScheme.primary.withValues(
        alpha: 0.11,
      )
          : colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.38),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(19),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary
                      .withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      folder.name.trim().isEmpty
                          ? 'Unnamed Folder'
                          : folder.name,
                      style: theme
                          .textTheme.titleSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${folder.noteCount} notes',
                      style: theme
                          .textTheme.bodySmall
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: selected
                    ? colorScheme.primary
                    : colorScheme
                    .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}