import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/app_controller.dart';
import '../controllers/image_controller.dart';
import '../controllers/audio_controller.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AppController appController = Get.find<AppController>();
  final ImageController imageController = Get.find<ImageController>();
  final AudioController audioController = Get.find<AudioController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.waves, size: 80, color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'WaveCode',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Audio ↔ Image Converter',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),

                SizedBox(height: 80),

                // Encode Button
                _buildActionButton(
                      icon: Icons.mic,
                      title: 'Encode Sound',
                      subtitle: 'Convert audio to image',
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.teal.shade400],
                      ),
                      onTap: () => Get.toNamed('/encode'),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: -0.3),

                SizedBox(height: 24),

                // Decode Button
                _buildActionButton(
                      icon: Icons.image,
                      title: 'Decode Image',
                      subtitle: 'Convert image to audio',
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.red.shade400],
                      ),
                      onTap: () => Get.toNamed('/decode'),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideX(begin: 0.3),

                SizedBox(height: 60),

                // Info text
                Text(
                  'Transform your audio into stunning visual representations',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                SizedBox(height: 32),
                // Simple Gallery/History
                Obx(
                  () => imageController.history.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: imageController.history.length,
                                itemBuilder: (context, index) {
                                  final item =
                                      imageController.history[imageController
                                              .history
                                              .length -
                                          1 -
                                          index];
                                  return GestureDetector(
                                    onTap: () async {
                                      if (item.imagePath.isNotEmpty) {
                                        Get.dialog(
                                          Dialog(
                                            child: Image.file(
                                              File(item.imagePath),
                                            ),
                                          ),
                                        );
                                      } else if (item.audioPath.isNotEmpty) {
                                        // Play or pause audio from history
                                        if (audioController.isPlaying.value &&
                                            audioController
                                                    .recordingPath
                                                    .value ==
                                                item.audioPath) {
                                          await audioController.stopPlaying();
                                        } else {
                                          await audioController.playAudio(
                                            item.audioPath,
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: 100,
                                      margin: EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (item.imagePath.isNotEmpty)
                                            Icon(
                                              Icons.image,
                                              color: Colors.white,
                                              size: 32,
                                            )
                                          else ...[
                                            Obx(
                                              () => Icon(
                                                (audioController
                                                            .isPlaying
                                                            .value &&
                                                        audioController
                                                                .recordingPath
                                                                .value ==
                                                            item.audioPath)
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_filled,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ],
                                          SizedBox(height: 8),
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            DateFormat(
                                              'MM/dd HH:mm',
                                            ).format(item.createdAt),
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
