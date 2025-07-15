class AudioImageModel {
  final String id;
  final String audioPath;
  final String imagePath;
  final DateTime createdAt;
  final String name;
  final int duration;
  final int fileSize;

  AudioImageModel({
    required this.id,
    required this.audioPath,
    required this.imagePath,
    required this.createdAt,
    required this.name,
    required this.duration,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audioPath': audioPath,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'duration': duration,
      'fileSize': fileSize,
    };
  }

  factory AudioImageModel.fromJson(Map<String, dynamic> json) {
    return AudioImageModel(
      id: json['id'],
      audioPath: json['audioPath'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'],
      duration: json['duration'],
      fileSize: json['fileSize'],
    );
  }
}