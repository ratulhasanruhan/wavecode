import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AppController extends GetxController {
  final RxString appDocumentsPath = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeDirectories();
  }

  Future<void> initializeDirectories() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      appDocumentsPath.value = directory.path;

      // Create subdirectories
      await Directory('${directory.path}/images').create(recursive: true);
      await Directory('${directory.path}/audio').create(recursive: true);
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize directories: $e');
    }
  }

  String get imagesPath => '${appDocumentsPath.value}/images';
  String get audioPath => '${appDocumentsPath.value}/audio';
}