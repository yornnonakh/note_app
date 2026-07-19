abstract final class ApiEndpoints {
  // Authentication
  static const String login = '/api/auth/login';

  // Confirm this endpoint with your backend.
  static const String register = '/api/auth/register';

  // Folder
  static const String folders = '/api/folder';

  static const String saveFolder =
      '/api/folder/save';

  static const String deleteRestoreFolder =
      '/api/folder/delete-restore';

  // Note
  static const String notes = '/api/note';

  static const String saveNote =
      '/api/note/save';

  static const String saveNoteContent =
      '/api/note/save-content';

  static const String uploadAttachment =
      '/api/note/attachment';

  static const String updateNoteState =
      '/api/note/update-state';

  static String noteDetail(int id) {
    return '/api/note/$id';
  }
}