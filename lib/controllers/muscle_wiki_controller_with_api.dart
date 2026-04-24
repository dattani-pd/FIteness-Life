import 'muscle_wiki_controller.dart';

/// API-enabled MuscleWiki controller.
///
/// Current app uses `MuscleWikiController` which has `apiDisabled = true` to avoid
/// iOS blank screens when the upstream API returns 401/403.
///
/// When you want to re-enable API calls, use this controller instead:
/// `Get.put(MuscleWikiControllerWithApi());`
class MuscleWikiControllerWithApi extends MuscleWikiController {
  @override
  void onInit() {
    // Enable API before base onInit triggers initialization.
    apiDisabled.value = false;
    super.onInit();
  }
}

