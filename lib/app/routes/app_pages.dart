import 'package:get/get.dart';

import '../../feature/auth/presentation/binding/login_binding.dart';
import '../../feature/auth/presentation/view/login_view.dart';
import '../../feature/notes/presentation/bindings/home_binding.dart';
import '../../feature/notes/presentation/bindings/note_editor_binding.dart';
import '../../feature/notes/presentation/view/home_view.dart';
import '../../feature/notes/presentation/view/note_editor_view.dart';
import '../controllers/splash_controllers.dart';
import '../views/splash_views.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        // Use Get.put instead of Get.lazyPut.
        // This immediately creates SplashController.
        Get.put<SplashController>(
          SplashController(
            authRepository: Get.find(),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.noteEditor,
      page: () => const NoteEditorView(),
      binding: NoteEditorBinding(),
    ),
  ];
}