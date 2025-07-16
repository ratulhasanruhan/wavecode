import 'dart:developer';
import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'app_controller.dart';

class AudioController extends GetxController {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();

  final RxBool isRecording = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isRecorderInitialized = false.obs;
  final RxString recordingPath = ''.obs;
  final RxList<double> waveformData = <double>[].obs;
  final RxDouble recordingDuration = 0.0.obs;

  StreamSubscription? _waveformSimSubscription;

  @override
  void onInit() {
    super.onInit();
    initializeRecorder();
  }

  Future<void> initializeRecorder() async {
    try {
      final permission = await Permission.microphone.request();
      if (permission.isGranted) {
        await _recorder.openRecorder();
        isRecorderInitialized.value = true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize recorder: $e');
    }
  }

  Future<void> startRecording() async {
    if (!isRecorderInitialized.value) return;

    try {
      final audioDirPath = Get.find<AppController>().audioPath;
      final audioDir = Directory(audioDirPath);
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      final path = '$audioDirPath/recording.wav';

      waveformData.clear();
      isRecording.value = true;
      recordingPath.value = path;

      await _recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);

      // Start simulated waveform
      _waveformSimSubscription = _generateWaveformData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      isRecording.value = false;
      await _waveformSimSubscription?.cancel();
      _waveformSimSubscription = null;
      // After recording, load waveform from the recorded file
      if (recordingPath.value.isNotEmpty) {
        await loadAudioWaveform(recordingPath.value);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop recording: $e');
    }
  }

  Future<String?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        recordingPath.value = result.files.single.path!;
        await loadAudioWaveform(result.files.single.path!);
        return result.files.single.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick audio file: $e');
    }
    return null;
  }

  Future<void> playAudio(String path) async {
    try {
      await _player.setFilePath(path);
      await _player.play();
      isPlaying.value = true;

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to play audio: $e');
    }
  }

  Future<void> stopPlaying() async {
    try {
      await _player.stop();
      isPlaying.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop audio: $e');
    }
  }

  Future<Uint8List> getAudioData(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }

  // Returns a StreamSubscription so it can be cancelled
  StreamSubscription _generateWaveformData() {
    return Stream.periodic(Duration(milliseconds: 100), (i) {
      if (isRecording.value) {
        final amplitude = math.Random().nextDouble() * 2 - 1;
        waveformData.add(amplitude);
        if (waveformData.length > 100) {
          waveformData.removeAt(0);
        }
      }
    }).listen((_) {});
  }

  Future<void> loadAudioWaveform(String path) async {
    try {
      final audioData = await getAudioData(path);
      waveformData.clear();

      // Improved waveform extraction: use PCM amplitude
      // For 16-bit PCM WAV, every 2 bytes is a sample
      for (int i = 44; i < audioData.length; i += 200) {
        // skip WAV header, sample every 200 bytes
        if (i + 1 < audioData.length) {
          int sample = audioData[i] | (audioData[i + 1] << 8);
          // Convert to signed 16-bit
          if (sample & 0x8000 != 0) sample = sample - 0x10000;
          double amplitude = sample / 32768.0;
          waveformData.add(amplitude);
        }
      }
    } catch (e) {
      log('Error loading waveform: $e');
    }
  }

  @override
  void onClose() {
    _recorder.closeRecorder();
    _player.dispose();
    _waveformSimSubscription?.cancel();
    super.onClose();
  }
}
