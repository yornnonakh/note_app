abstract final class ApiEndpoints {
  // Authentication
  static const String login = '/api/auth/login';

  // Confirm this route with your backend developer.
  static const String register = '/api/auth/register';

  // Folders
  static const String folders = '/api/folder';
  static const String saveFolder = '/api/folder/save';
  static const String deleteRestoreFolder =
      '/api/folder/delete-restore';

  // Notes
  static const String notes = '/api/note';
  static const String saveNote = '/api/note/save';
  static const String saveNoteContent =
      '/api/note/save-content';
  static const String uploadAttachment =
      '/api/note/attachment';

  // Change to /api/note/state when confirmed by backend.
  static const String updateNoteState =
      '/api/note/update-state';

  static String noteDetail(int noteId) {
    return '/api/note/$noteId';
  }
}