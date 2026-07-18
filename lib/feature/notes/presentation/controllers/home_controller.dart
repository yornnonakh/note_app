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

  final RxList<FolderEntity> folders =
      <FolderEntity>[].obs;

  final RxList<NoteEntity> notes =
      <NoteEntity>[].obs;

  final RxnInt selectedFolderId = RxnInt();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<NoteEntity> get visibleNotes {
    final int? folderId = selectedFolderId.value;

    if (folderId == null) {
      return notes;
    }

    return notes
        .where((NoteEntity note) {
      return note.folderId == folderId;
    })
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final List<dynamic> results = await Future.wait([
        folderRepository.getFolders(),
        noteRepository.getNotes(),
      ]);

      folders.assignAll(
        results[0] as List<FolderEntity>,
      );

      notes.assignAll(
        results[1] as List<NoteEntity>,
      );
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNotes() async {
    try {
      final List<NoteEntity> result =
      await noteRepository.getNotes();

      notes.assignAll(result);
    } catch (error) {
      errorMessage.value = error.toString();
    }
  }

  void selectAllNotes() {
    selectedFolderId.value = null;
  }

  void selectFolder(int folderId) {
    selectedFolderId.value = folderId;
  }

  Future<void> createFolder({
    required String name,
  }) async {
    try {
      await folderRepository.saveFolder(
        id: 0,
        name: name,
        iconName: 'folder',
        colorValue: '#2196F3',
        sortOrder: folders.length + 1,
      );

      folders.assignAll(
        await folderRepository.getFolders(),
      );
    } catch (error) {
      Get.snackbar(
        'Folder error',
        error.toString(),
      );
    }
  }

  Future<void> createNote({
    required String title,
  }) async {
    if (folders.isEmpty) {
      Get.snackbar(
        'Folder required',
        'Create a folder before creating a note.',
      );
      return;
    }

    try {
      final int folderId =
          selectedFolderId.value ?? folders.first.id;

      final int noteId =
      await noteRepository.saveNote(
        noteId: 0,
        folderId: folderId,
        title: title,
      );

      await Get.toNamed(
        AppRoutes.noteEditor,
        arguments: noteId,
      );

      await loadNotes();
    } catch (error) {
      Get.snackbar(
        'Note error',
        error.toString(),
      );
    }
  }

  Future<void> togglePin(NoteEntity note) async {
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
        'Update failed',
        error.toString(),
      );
    }
  }

  Future<void> openNote(int noteId) async {
    await Get.toNamed(
      AppRoutes.noteEditor,
      arguments: noteId,
    );

    await loadNotes();
  }

  Future<void> logout() async {
    await authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}