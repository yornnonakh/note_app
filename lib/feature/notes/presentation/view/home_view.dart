import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../folders/domain/entities/folder_entity.dart';
import '../../domain/entities/note_entity.dart';
import '../controllers/home_controller.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(
              () =>
              Text(
                controller.selectedFolderId.value == null
                    ? 'All Notes'
                    : _selectedFolderName(),
              ),
        ),
        actions: [
          IconButton(
            onPressed: controller.loadAll,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'logout') {
                controller.logout();
              }
            },
            itemBuilder: (_) {
              return const [
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Obx(
                () =>
                Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.note_alt_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text(
                        'Piisiit Note',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () =>
                            _showCreateFolder(context),
                        icon:
                        const Icon(Icons.create_new_folder),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading:
                      const Icon(Icons.notes_outlined),
                      title: const Text('All Notes'),
                      selected:
                      controller.selectedFolderId.value ==
                          null,
                      onTap: () {
                        controller.selectAllNotes();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.folders.length,
                        itemBuilder: (context, index) {
                          final FolderEntity folder =
                          controller.folders[index];

                          return ListTile(
                            leading: const Icon(
                              Icons.folder_outlined,
                            ),
                            title: Text(folder.name),
                            selected: controller
                                .selectedFolderId.value ==
                                folder.id,
                            onTap: () {
                              controller
                                  .selectFolder(folder.id);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNote(context),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: controller.loadAll,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final List<NoteEntity> notes =
            controller.visibleNotes;

        if (notes.isEmpty) {
          return const Center(
            child: Text('No notes found'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAll,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            itemCount: notes.length,
            separatorBuilder: (_, _) {
              return const SizedBox(height: 10);
            },
            itemBuilder: (context, index) {
              final NoteEntity note = notes[index];

              final Color cardColor = isDark
                  ? const Color(0xFF1B1D22)
                  : Colors.white;

              final Color borderColor =
              colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.18 : 0.35,
              );

              return Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(18),
                  onTap: () =>
                      controller.openNote(note.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                        color: borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title.isEmpty
                                    ? 'Untitled Note'
                                    : note.title,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: theme
                                    .textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _notePreview(note),
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                                style: theme
                                    .textTheme.bodyMedium
                                    ?.copyWith(
                                  color: colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              controller.togglePin(note),
                          icon: Icon(
                            note.isPinned
                                ? Icons.push_pin
                                : Icons
                                .push_pin_outlined,
                            color: note.isPinned
                                ? colorScheme.primary
                                : colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  String _selectedFolderName() {
    final int? selectedId =
        controller.selectedFolderId.value;

    for (final FolderEntity folder
    in controller.folders) {
      if (folder.id == selectedId) {
        return folder.name;
      }
    }

    return 'Notes';
  }

  String _notePreview(NoteEntity note) {
    for (final Map<String, dynamic> block
    in note.content) {
      if (block['type'] == 'text') {
        return block['text']?.toString() ??
            'Open note';
      }
    }

    return note.isArchived
        ? 'Archived note'
        : 'Open note';
  }

  Future<void> _showCreateFolder(
      BuildContext context,
      ) async {
    String folderName = '';

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create Folder'),
          content: TextField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (String value) {
              folderName = value;
            },
            onSubmitted: (String value) {
              final String name = value.trim();

              if (name.isEmpty) {
                return;
              }

              Navigator.of(dialogContext).pop(name);
            },
            decoration: const InputDecoration(
              labelText: 'Folder name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String name = folderName.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(name);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    await controller.createFolder(
      name: result,
    );
  }
  Future<void> _showCreateNote(
      BuildContext context,
      ) async {
    String noteTitle = '';

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create Note'),
          content: TextField(
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (String value) {
              noteTitle = value;
            },
            onSubmitted: (String value) {
              final String title = value.trim();

              if (title.isEmpty) {
                return;
              }

              Navigator.of(dialogContext).pop(title);
            },
            decoration: const InputDecoration(
              labelText: 'Note title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final String title = noteTitle.trim();

                if (title.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(title);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (result == null || result.isEmpty) {
      return;
    }

    await controller.createNote(
      title: result,
    );
  }}