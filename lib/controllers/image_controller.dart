import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'app_controller.dart';
import 'audio_controller.dart';
import '../models/audio_image_model.dart';

class ImageController extends GetxController {
  final RxString generatedImagePath = ''.obs;
  final RxString selectedImagePath = ''.obs;
  final RxBool isGenerating = false.obs;
  final RxBool isDecoding = false.obs;

  // In-memory history
  final RxList<AudioImageModel> history = <AudioImageModel>[].obs;

  Future<String?> encodeAudioToImage(Uint8List audioData) async {
    try {
      isGenerating.value = true;

      // Calculate image dimensions
      final dataLength = audioData.length;
      final imageSize = math.sqrt(dataLength / 3).ceil();

      // Create image
      final image = img.Image(width: imageSize, height: imageSize);

      // Convert audio data to RGB values
      int dataIndex = 0;
      for (int y = 0; y < imageSize; y++) {
        for (int x = 0; x < imageSize; x++) {
          int r = dataIndex < dataLength ? audioData[dataIndex] : 0;
          int g = dataIndex + 1 < dataLength ? audioData[dataIndex + 1] : 0;
          int b = dataIndex + 2 < dataLength ? audioData[dataIndex + 2] : 0;

          image.setPixel(x, y, img.ColorRgb8(r, g, b));
          dataIndex += 3;
        }
      }

      // Save image with static name
      final imagesDirPath = Get.find<AppController>().imagesPath;
      final imagePath = '$imagesDirPath/encoded.png';
      final imagesDir = Directory(imagesDirPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final file = File(imagePath);
      await file.writeAsBytes(img.encodePng(image));

      generatedImagePath.value = imagePath;
      isGenerating.value = false;

      // Add to history
      history.add(
        AudioImageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          audioPath: '',
          imagePath: imagePath,
          createdAt: DateTime.now(),
          name: 'Encoded Image',
          duration: 0,
          fileSize: audioData.length,
        ),
      );

      return imagePath;
    } catch (e) {
      isGenerating.value = false;
      Get.snackbar('Error', 'Failed to encode audio to image: $e');
      return null;
    }
  }

  Future<Uint8List?> decodeImageToAudio(String imagePath) async {
    try {
      isDecoding.value = true;

      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Extract audio data from RGB values
      final audioData = <int>[];
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          audioData.add(pixel.r.toInt());
          audioData.add(pixel.g.toInt());
          audioData.add(pixel.b.toInt());
        }
      }

      // Create WAV header
      final wavData = _createWavFile(Uint8List.fromList(audioData));

      // Save decoded audio with static name
      final audioDirPath = Get.find<AppController>().audioPath;
      final audioPath = '$audioDirPath/decoded.wav';
      final audioDir = Directory(audioDirPath);
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final audioFile = File(audioPath);
      await audioFile.writeAsBytes(wavData);

      // Set decoded audio path for UI access
      Get.find<AudioController>().recordingPath.value = audioPath;

      // Add to history
      history.add(
        AudioImageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          audioPath: audioPath,
          imagePath: imagePath,
          createdAt: DateTime.now(),
          name: 'Decoded Audio',
          duration: 0,
          fileSize: wavData.length,
        ),
      );

      isDecoding.value = false;
      return wavData;
    } catch (e) {
      isDecoding.value = false;
      Get.snackbar('Error', 'Failed to decode image to audio: $e');
      return null;
    }
  }

  Future<String?> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        selectedImagePath.value = result.files.single.path!;
        return result.files.single.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
    return null;
  }

  Uint8List _createWavFile(Uint8List audioData) {
    final sampleRate = 44100;
    final channels = 1;
    final bitsPerSample = 16;

    final header = <int>[];

    // WAV header
    header.addAll('RIFF'.codeUnits);
    header.addAll(_int32ToBytes(audioData.length + 36));
    header.addAll('WAVE'.codeUnits);
    header.addAll('fmt '.codeUnits);
    header.addAll(_int32ToBytes(16));
    header.addAll(_int16ToBytes(1));
    header.addAll(_int16ToBytes(channels));
    header.addAll(_int32ToBytes(sampleRate));
    header.addAll(_int32ToBytes(sampleRate * channels * bitsPerSample ~/ 8));
    header.addAll(_int16ToBytes(channels * bitsPerSample ~/ 8));
    header.addAll(_int16ToBytes(bitsPerSample));
    header.addAll('data'.codeUnits);
    header.addAll(_int32ToBytes(audioData.length));

    return Uint8List.fromList(header + audioData);
  }

  List<int> _int32ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  List<int> _int16ToBytes(int value) {
    return [value & 0xFF, (value >> 8) & 0xFF];
  }
}
