import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../controllers/audio_controller.dart';
import '../controllers/image_controller.dart';
import '../widgets/image_display.dart';
import '../widgets/waveform_painter.dart';

class EncodeView extends StatelessWidget {
  EncodeView({super.key});

  final AudioController audioController = Get.find<AudioController>();
  final ImageController imageController = Get.find<ImageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encode Audio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.teal.shade400],
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
              Colors.green.shade400.withValues(alpha: 0.1),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // Waveform Display
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Obx(() => WaveformPainter(
                    waveformData: audioController.waveformData,
                    isRecording: audioController.isRecording.value,
                  )),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                SizedBox(height: 32),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Record Button
                    Obx(() => _buildControlButton(
                      icon: audioController.isRecording.value
                          ? Icons.stop : Icons.mic,
                      label: audioController.isRecording.value
                          ? 'Stop' : 'Record',
                      color: audioController.isRecording.value
                          ? Colors.red : Colors.green,
                      onTap: audioController.isRecording.value
                          ? audioController.stopRecording
                          : audioController.startRecording,
                    )),

                    // Upload Button
                    _buildControlButton(
                      icon: Icons.upload_file,
                      label: 'Upload',
                      color: Colors.blue,
                      onTap: audioController.pickAudioFile,
                    ),

                    // Play Button
                    Obx(() => _buildControlButton(
                      icon: audioController.isPlaying.value
                          ? Icons.pause : Icons.play_arrow,
                      label: audioController.isPlaying.value
                          ? 'Pause' : 'Play',
                      color: Colors.purple,
                      onTap: audioController.isPlaying.value
                          ? audioController.stopPlaying
                          : () => audioController.playAudio(
                          audioController.recordingPath.value),
                    )),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                SizedBox(height: 32),

                // Generate Image Button
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: audioController.recordingPath.value.isNotEmpty
                        ? _generateImage : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.red.shade400],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: imageController.isGenerating.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.white),
                            SizedBox(width: 12),
                            Text(
                              'Generate Image',
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
                )),

                SizedBox(height: 32),

                // Generated Image Display
                Expanded(
                  child: Obx(() => imageController.generatedImagePath.value.isNotEmpty
                      ? Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ImageDisplay(
                            imagePath: imageController.generatedImagePath.value,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.save,
                                label: 'Save',
                                onTap: () => _saveImage(),
                              ),
                              _buildActionButton(
                                icon: Icons.share,
                                label: 'Share',
                                onTap: () => _shareImage(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).scale(begin: Offset(0.8, 0.8))
                      : Center(
                    child: Text(
                      'Generated image will appear here',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ),
                ),
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
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateImage() async {
    try {
      final audioData = await audioController.getAudioData(
        audioController.recordingPath.value,
      );
      await imageController.encodeAudioToImage(audioData);
      Get.snackbar(
        'Success',
        'Image generated successfully!',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate image: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveImage() async {
    Get.snackbar(
      'Saved',
      'Image saved to gallery',
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  Future<void> _shareImage() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out this generated image from WaveCode!',
          title: 'WaveCode Image',
          files: [
            XFile(imageController.generatedImagePath.value),
          ]
        )
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share image: $e',
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }
}