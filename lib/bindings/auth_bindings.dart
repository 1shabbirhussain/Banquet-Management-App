import 'package:event_ease/controllers/add_banquet_controller.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class AddBanquetBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => AddBanquetController());
  }

}
