import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../controllers/app_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/image_controller.dart';
import '../widgets/waveform_painter.dart';

class DecodeView extends StatelessWidget {
  DecodeView({super.key});

  final AudioController audioController = Get.find<AudioController>();
  final ImageController imageController = Get.find<ImageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Decode Image'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.red.shade400],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400.withValues(alpha: 0.1),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Image Selection
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Obx(
                    () => imageController.selectedImagePath.value.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(imageController.selectedImagePath.value),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Select an image to decode',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                SizedBox(height: 32),

                // Select Image Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: imageController.pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.purple.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Select Image',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                SizedBox(height: 32),

                // Decode Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed:
                          imageController.selectedImagePath.value.isNotEmpty
                          ? _decodeImage
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.teal.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: imageController.isDecoding.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.audiotrack, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text(
                                      'Decode to Audio',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Decoded Waveform Display
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Obx(
                    () => WaveformPainter(
                      waveformData: audioController.waveformData,
                      isRecording: false,
                      color: Colors.green,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                SizedBox(height: 32),

                // Audio Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Play Button
                    Obx(
                      () => _buildControlButton(
                        icon: audioController.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        label: audioController.isPlaying.value
                            ? 'Pause'
                            : 'Play',
                        color: Colors.green,
                        onTap: audioController.isPlaying.value
                            ? audioController.stopPlaying
                            : () => audioController.playAudio(
                                audioController.recordingPath.value,
                              ),
                      ),
                    ),

                    // Save Button
                    _buildControlButton(
                      icon: Icons.save,
                      label: 'Save',
                      color: Colors.blue,
                      onTap: _saveAudio,
                    ),

                    // Share Button
                    _buildControlButton(
                      icon: Icons.share,
                      label: 'Share',
                      color: Colors.purple,
                      onTap: _shareAudio,
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

                SizedBox(height: 32),

                // Info Text
                Text(
                  'Decoded audio will be playable above',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.8), color],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _decodeImage() async {
    try {
      final audioData = await imageController.decodeImageToAudio(
        imageController.selectedImagePath.value,
      );

      if (audioData != null) {
        // Load the decoded audio for playback
        await audioController.loadAudioWaveform(
          '${Get.find<AppController>().audioPath}/decoded_${DateTime.now().millisecondsSinceEpoch}.wav',
        );

        Get.snackbar(
          'Success',
          'Audio decoded successfully!',
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to decode image: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveAudio() async {
    Get.snackbar(
      'Saved',
      'Audio saved to device',
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  Future<void> _shareAudio() async {
    try {
      if (audioController.recordingPath.value.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(audioController.recordingPath.value)],
            text: 'Check out this audio file!',
            subject: 'Audio from WaveCode',
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share audio: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }
}
