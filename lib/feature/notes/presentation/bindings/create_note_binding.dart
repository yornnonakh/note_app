import 'package:get/get.dart';
import '../controllers/create_note_controller.dart';
import '../controllers/home_controller.dart';

class CreateNoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNoteController>(
          () => CreateNoteController(
        homeController:
        Get.find<HomeController>(),
      ),
    );
  }
}