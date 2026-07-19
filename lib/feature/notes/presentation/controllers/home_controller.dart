import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../folders/domain/entities/folder_entity.dart';
import '../../../folders/domain/repositories/folder_repository_impl.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';

class HomeController extends GetxController {
  final FolderRepository folderRepository;
  final NoteRepository noteRepository;
  final AuthRepository authRepository;

  HomeController({
    required this.folderRepository,
    required this.noteRepository,
    required this.authRepository,
  });

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  final RxList<FolderEntity> folders =
      <FolderEntity>[].obs;

  final RxList<NoteEntity> notes =
      <NoteEntity>[].obs;

  // null means "All Notes".
  final RxnInt selectedFolderId = RxnInt();

  // ---------------------------------------------------------------------------
  // Loading states
  // ---------------------------------------------------------------------------

  final RxBool isFoldersLoading = false.obs;
  final RxBool isNotesLoading = false.obs;

  // ---------------------------------------------------------------------------
  // Error states
  // ---------------------------------------------------------------------------

  final RxString folderErrorMessage = ''.obs;
  final RxString noteErrorMessage = ''.obs;

  // ---------------------------------------------------------------------------
  // Computed values
  // ---------------------------------------------------------------------------

  bool get isInitialLoading {
    return folders.isEmpty &&
        notes.isEmpty &&
        (isFoldersLoading.value ||
            isNotesLoading.value);
  }

  bool get hasFolderError {
    return folderErrorMessage.value.isNotEmpty;
  }

  bool get hasNoteError {
    return noteErrorMessage.value.isNotEmpty;
  }

  bool get hasFolders {
    return folders.isNotEmpty;
  }

  bool get hasNotes {
    return notes.isNotEmpty;
  }

  FolderEntity? get selectedFolder {
    final int? folderId =
        selectedFolderId.value;

    if (folderId == null) {
      return null;
    }

    for (final FolderEntity folder in folders) {
      if (folder.id == folderId) {
        return folder;
      }
    }

    return null;
  }

  String get selectedFolderName {
    final FolderEntity? folder =
        selectedFolder;

    if (folder == null) {
      return 'All Notes';
    }

    if (folder.name.trim().isEmpty) {
      return 'Unnamed Folder';
    }

    return folder.name;
  }

  int get selectedFolderNoteCount {
    final FolderEntity? folder =
        selectedFolder;

    if (folder != null) {
      return folder.noteCount;
    }

    if (notes.isNotEmpty) {
      return notes.length;
    }

    return folders.fold<int>(
      0,
          (
          int total,
          FolderEntity currentFolder,
          ) {
        return total + currentFolder.noteCount;
      },
    );
  }

  List<NoteEntity> get visibleNotes {
    final int? folderId =
        selectedFolderId.value;

    final List<NoteEntity> result;

    if (folderId == null) {
      result = notes.toList();
    } else {
      result = notes.where(
            (NoteEntity note) {
          return note.folderId == folderId;
        },
      ).toList();
    }

    // Show pinned notes first.
    result.sort(
          (
          NoteEntity first,
          NoteEntity second,
          ) {
        if (first.isPinned ==
            second.isPinned) {
          return 0;
        }

        return first.isPinned ? -1 : 1;
      },
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();

    loadAll();
  }

  // ---------------------------------------------------------------------------
  // Load data
  // ---------------------------------------------------------------------------

  Future<void> loadAll() async {
    await Future.wait<void>([
      loadFolders(),
      loadNotes(),
    ]);
  }

  Future<void> loadFolders() async {
    try {
      isFoldersLoading.value = true;
      folderErrorMessage.value = '';

      final List<FolderEntity> result =
      await folderRepository.getFolders();

      result.sort(
            (
            FolderEntity first,
            FolderEntity second,
            ) {
          return first.sortOrder.compareTo(
            second.sortOrder,
          );
        },
      );

      folders.assignAll(result);

      _validateSelectedFolder();
    } catch (error) {
      folderErrorMessage.value =
          _cleanError(error);
    } finally {
      isFoldersLoading.value = false;
    }
  }

  Future<void> loadNotes() async {
    try {
      isNotesLoading.value = true;
      noteErrorMessage.value = '';

      final List<NoteEntity> result =
      await noteRepository.getNotes();

      notes.assignAll(result);
    } catch (error) {
      // Keep existing notes when refresh fails.
      noteErrorMessage.value =
          _cleanError(error);
    } finally {
      isNotesLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Folder selection
  // ---------------------------------------------------------------------------

  void selectAllNotes() {
    selectedFolderId.value = null;
  }

  void selectFolder(int folderId) {
    final bool folderExists =
    folders.any(
          (FolderEntity folder) {
        return folder.id == folderId;
      },
    );

    if (!folderExists) {
      return;
    }

    selectedFolderId.value = folderId;
  }

  void _validateSelectedFolder() {
    final int? folderId =
        selectedFolderId.value;

    if (folderId == null) {
      return;
    }

    final bool folderStillExists =
    folders.any(
          (FolderEntity folder) {
        return folder.id == folderId;
      },
    );

    if (!folderStillExists) {
      selectedFolderId.value = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Create folder
  // ---------------------------------------------------------------------------

  Future<void> createFolder({
    required String name,
  }) async {
    final String cleanName = name.trim();

    if (cleanName.isEmpty) {
      Get.snackbar(
        'Folder name required',
        'Please enter a folder name.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      await folderRepository.saveFolder(
        id: 0,
        name: cleanName,
        iconName: 'folder',
        colorValue: '#5B7CFA',
        sortOrder: folders.length + 1,
      );

      await loadFolders();

      Get.snackbar(
        'Folder created',
        '$cleanName was created successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Create folder failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Update folder
  // ---------------------------------------------------------------------------

  Future<void> updateFolder({
    required FolderEntity folder,
    required String name,
    String? iconName,
    String? colorValue,
    int? sortOrder,
  }) async {
    final String cleanName = name.trim();

    if (cleanName.isEmpty) {
      Get.snackbar(
        'Folder name required',
        'Please enter a folder name.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      await folderRepository.saveFolder(
        id: folder.id,
        name: cleanName,
        iconName:
        iconName?.trim().isNotEmpty == true
            ? iconName!.trim()
            : folder.iconName,
        colorValue:
        colorValue?.trim().isNotEmpty == true
            ? colorValue!.trim()
            : folder.colorValue,
        sortOrder:
        sortOrder ?? folder.sortOrder,
      );

      await loadFolders();

      Get.snackbar(
        'Folder updated',
        '$cleanName was updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Update folder failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Delete or restore folder
  // ---------------------------------------------------------------------------

  Future<void> deleteOrRestoreFolder({
    required int folderId,
    required bool isDelete,
  }) async {
    try {
      await folderRepository
          .deleteOrRestoreFolder(
        id: folderId,
        isDelete: isDelete,
      );

      if (isDelete &&
          selectedFolderId.value ==
              folderId) {
        selectedFolderId.value = null;
      }

      await loadFolders();

      // Reload notes because deleting a folder
      // may change the note list.
      await loadNotes();

      Get.snackbar(
        isDelete
            ? 'Folder deleted'
            : 'Folder restored',
        isDelete
            ? 'The folder was deleted successfully.'
            : 'The folder was restored successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        isDelete
            ? 'Delete folder failed'
            : 'Restore folder failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Create note
  // ---------------------------------------------------------------------------

  Future<void> createNote({
    required String title,
  }) async {
    final String cleanTitle =
    title.trim();

    if (cleanTitle.isEmpty) {
      Get.snackbar(
        'Note title required',
        'Please enter a note title.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    if (folders.isEmpty) {
      Get.snackbar(
        'Folder required',
        'Create a folder before creating a note.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      final int folderId =
          selectedFolderId.value ??
              folders.first.id;

      final int noteId =
      await noteRepository.saveNote(
        noteId: 0,
        folderId: folderId,
        title: cleanTitle,
      );

      await Get.toNamed(
        AppRoutes.noteEditor,
        arguments: noteId,
      );

      await Future.wait<void>([
        loadFolders(),
        loadNotes(),
      ]);
    } catch (error) {
      Get.snackbar(
        'Create note failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Open note
  // ---------------------------------------------------------------------------

  Future<void> openNote(
      int noteId,
      ) async {
    await Get.toNamed(
      AppRoutes.noteEditor,
      arguments: noteId,
    );

    await Future.wait<void>([
      loadNotes(),
      loadFolders(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Pin note
  // ---------------------------------------------------------------------------

  Future<void> togglePin(
      NoteEntity note,
      ) async {
    try {
      await noteRepository.updateState(
        noteId: note.id,
        isPinned: !note.isPinned,
        isArchived: note.isArchived,
        isLocked: note.isLocked,
      );

      await loadNotes();
    } catch (error) {
      Get.snackbar(
        'Update note failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Archive note
  // ---------------------------------------------------------------------------

  Future<void> archiveNote(
      NoteEntity note,
      ) async {
    try {
      await noteRepository.updateState(
        noteId: note.id,
        isPinned: note.isPinned,
        isArchived: !note.isArchived,
        isLocked: note.isLocked,
      );

      await loadNotes();

      Get.snackbar(
        note.isArchived
            ? 'Removed from archive'
            : 'Note archived',
        note.isArchived
            ? 'The note was removed from the archive.'
            : 'The note was archived successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Archive update failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Lock note
  // ---------------------------------------------------------------------------

  Future<void> lockNote(
      NoteEntity note,
      ) async {
    try {
      await noteRepository.updateState(
        noteId: note.id,
        isPinned: note.isPinned,
        isArchived: note.isArchived,
        isLocked: !note.isLocked,
      );

      await loadNotes();

      Get.snackbar(
        note.isLocked
            ? 'Note unlocked'
            : 'Note locked',
        note.isLocked
            ? 'The note was unlocked successfully.'
            : 'The note was locked successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Lock update failed',
        _cleanError(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    try {
      await authRepository.logout();
    } finally {
      Get.offAllNamed(
        AppRoutes.login,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _cleanError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'ApiException: ',
      '',
    )
        .trim();
  }
}