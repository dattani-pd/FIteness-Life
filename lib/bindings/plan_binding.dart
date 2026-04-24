import 'package:get/get.dart';
import '../controllers/controller.dart';

class PlanBinding extends Bindings {
  @override
  void dependencies() {
    // LazyPut loads the controller only when the screen opens
    Get.lazyPut<PlanController>(() => PlanController());
  }
}