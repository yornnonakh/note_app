import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_app/feature/main/presentation/widgets/app_liquid_background_widget.dart';
import 'package:note_app/feature/main/presentation/widgets/main_tab_header_widget.dart';
import '../../../folders/domain/entities/folder_entity.dart';
import '../../domain/entities/note_entity.dart';
import '../controllers/home_controller.dart';

class NoteListView
    extends GetView<HomeController> {
  const NoteListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: AppLiquidBackgroundWidget(),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  0,
                ),
                child: Obx(
                      () => MainTabHeaderWidget(
                    title: controller
                        .selectedFolderName,
                    subtitle:
                    '${controller.visibleNotes.length} notes',
                    onRefresh: controller.loadAll,
                    onAdd: () {
                      _showCreateNoteDialog(
                        context,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                    () => _FolderFilterStrip(
                  folders: controller.folders,
                  selectedFolderId: controller
                      .selectedFolderId.value,
                  onSelectAll:
                  controller.selectAllNotes,
                  onSelectFolder:
                  controller.selectFolder,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(
                      () => _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.isNotesLoading.value &&
        controller.notes.isEmpty) {
      return const Center(
        child:
        CircularProgressIndicator.adaptive(),
      );
    }

    if (controller.hasNoteError) {
      return _NoteErrorState(
        message: _cleanServerMessage(
          controller.noteErrorMessage.value,
        ),
        onRetry: controller.loadNotes,
      );
    }

    final List<NoteEntity> notes =
        controller.visibleNotes;

    if (notes.isEmpty) {
      return _EmptyNoteState(
        hasFolders:
        controller.folders.isNotEmpty,
        onCreate: () {
          _showCreateNoteDialog(context);
        },
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: controller.loadAll,
      child: ListView.separated(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          120,
        ),
        itemCount: notes.length,
        separatorBuilder: (_, _) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (
            BuildContext context,
            int index,
            ) {
          final NoteEntity note = notes[index];

          return _NoteCard(
            note: note,
            folderName:
            _folderNameFor(note.folderId),
            onTap: () {
              controller.openNote(note.id);
            },
            onMore: () {
              _showNoteActions(
                context,
                note,
              );
            },
          );
        },
      ),
    );
  }

  String _folderNameFor(int folderId) {
    for (final FolderEntity folder
    in controller.folders) {
      if (folder.id == folderId) {
        return folder.name.trim().isEmpty
            ? 'Unnamed Folder'
            : folder.name;
      }
    }

    return 'Notes';
  }

  Future<void> _showCreateNoteDialog(
      BuildContext context,
      ) async {
    if (controller.folders.isEmpty) {
      Get.snackbar(
        'Folder required',
        'Create a folder before creating a note.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    String noteTitle = '';

    final String? result =
    await showCupertinoDialog<String>(
      context: context,
      builder: (
          BuildContext dialogContext,
          ) {
        return CupertinoAlertDialog(
          title: const Text('New Note'),
          content: Padding(
            padding:
            const EdgeInsets.only(top: 14),
            child: CupertinoTextField(
              autofocus: true,
              placeholder: 'Note title',
              textInputAction:
              TextInputAction.done,
              onChanged: (String value) {
                noteTitle = value;
              },
              onSubmitted: (String value) {
                final String title =
                value.trim();

                if (title.isNotEmpty) {
                  Navigator.of(dialogContext)
                      .pop(title);
                }
              },
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                final String title =
                noteTitle.trim();

                if (title.isNotEmpty) {
                  Navigator.of(dialogContext)
                      .pop(title);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == null ||
        result.trim().isEmpty) {
      return;
    }

    await controller.createNote(
      title: result,
    );
  }

  Future<void> _showNoteActions(
      BuildContext context,
      NoteEntity note,
      ) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (
          BuildContext sheetContext,
          ) {
        return CupertinoActionSheet(
          title: Text(
            note.title.trim().isEmpty
                ? 'Untitled Note'
                : note.title,
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                controller.togglePin(note);
              },
              child: Text(
                note.isPinned
                    ? 'Unpin Note'
                    : 'Pin Note',
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                controller.archiveNote(note);
              },
              child: Text(
                note.isArchived
                    ? 'Remove from Archive'
                    : 'Archive Note',
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                controller.lockNote(note);
              },
              child: Text(
                note.isLocked
                    ? 'Unlock Note'
                    : 'Lock Note',
              ),
            ),
          ],
          cancelButton:
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetContext).pop();
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  String _cleanServerMessage(
      String message,
      ) {
    if (message.contains('PlainText') ||
        message.contains('PreviewText')) {
      return 'The backend note database is '
          'missing the PlainText and PreviewText '
          'columns. The backend database or query '
          'must be corrected.';
    }

    return message;
  }
}

class _FolderFilterStrip
    extends StatelessWidget {
  final List<FolderEntity> folders;
  final int? selectedFolderId;
  final VoidCallback onSelectAll;
  final ValueChanged<int> onSelectFolder;

  const _FolderFilterStrip({
    required this.folders,
    required this.selectedFolderId,
    required this.onSelectAll,
    required this.onSelectFolder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding:
        const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: folders.length + 1,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (
            BuildContext context,
            int index,
            ) {
          if (index == 0) {
            return _FilterChip(
              label: 'All',
              selected: selectedFolderId == null,
              onTap: onSelectAll,
            );
          }

          final FolderEntity folder =
          folders[index - 1];

          return _FilterChip(
            label: folder.name.trim().isEmpty
                ? 'Unnamed'
                : folder.name,
            selected:
            selectedFolderId == folder.id,
            onTap: () {
              onSelectFolder(folder.id);
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surface.withValues(
            alpha: 0.72,
          ),
          borderRadius:
          BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? colorScheme.primary
                : colorScheme.outlineVariant
                .withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteEntity note;
  final String folderName;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _NoteCard({
    required this.note,
    required this.folderName,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1B1D22)
                : Colors.white,
            borderRadius:
            BorderRadius.circular(24),
            border: Border.all(
              color: note.isPinned
                  ? colorScheme.primary
                  .withValues(alpha: 0.45)
                  : colorScheme.outlineVariant
                  .withValues(
                alpha:
                isDark ? 0.20 : 0.38,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(
                  alpha:
                  isDark ? 0.15 : 0.045,
                ),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.75),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Icon(
                      note.isLocked
                          ? Icons.lock_outline_rounded
                          : Icons
                          .description_outlined,
                      color: colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          note.title.trim().isEmpty
                              ? 'Untitled Note'
                              : note.title,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: theme
                              .textTheme.titleMedium
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          folderName,
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onMore,
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                _preview(note),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                  color: colorScheme
                      .onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              if (note.isPinned ||
                  note.isArchived ||
                  note.isLocked) ...<Widget>[
                const SizedBox(height: 13),
                Wrap(
                  spacing: 7,
                  children: <Widget>[
                    if (note.isPinned)
                      const _NoteBadge(
                        icon:
                        Icons.push_pin_outlined,
                        label: 'Pinned',
                      ),
                    if (note.isArchived)
                      const _NoteBadge(
                        icon:
                        Icons.archive_outlined,
                        label: 'Archived',
                      ),
                    if (note.isLocked)
                      const _NoteBadge(
                        icon:
                        Icons.lock_outline_rounded,
                        label: 'Locked',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _preview(NoteEntity note) {
    if (note.isLocked) {
      return 'This note is locked.';
    }

    for (final Map<String, dynamic> block
    in note.content) {
      final String? type =
      block['type']?.toString();

      if (type == 'text') {
        final String text =
            block['text']?.toString().trim() ??
                '';

        if (text.isNotEmpty) {
          return text;
        }
      }

      if (type == 'checklist') {
        return 'Checklist content';
      }

      if (type == 'attachment') {
        return 'Attachment';
      }
    }

    return 'Tap to start writing.';
  }
}

class _NoteBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NoteBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary
            .withValues(alpha: 0.09),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 13,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNoteState extends StatelessWidget {
  final bool hasFolders;
  final VoidCallback onCreate;

  const _EmptyNoteState({
    required this.hasFolders,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 30,
          right: 30,
          bottom: 90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              hasFolders
                  ? Icons.note_add_outlined
                  : Icons
                  .create_new_folder_outlined,
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 18),
            Text(
              hasFolders
                  ? 'No notes yet'
                  : 'Create a folder first',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFolders
                  ? 'Create your first note in this folder.'
                  : 'A folder is required before creating a note.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            if (hasFolders) ...<Widget>[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCreate,
                icon:
                const Icon(Icons.add_rounded),
                label:
                const Text('Create Note'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NoteErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          30,
          20,
          30,
          100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.cloud_off_outlined,
              size: 58,
              color:
              Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 18),
            Text(
              'Notes are unavailable',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}