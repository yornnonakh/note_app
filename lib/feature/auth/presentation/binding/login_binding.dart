import 'package:get/get.dart';
import '../../domain/repositories/auth_repository.dart';
import '../constroller/login_constroller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
          () => LoginController(
        authRepository: Get.find<AuthRepository>(),
      ),
    );
  }
}