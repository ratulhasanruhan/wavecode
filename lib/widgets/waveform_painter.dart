import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformPainter extends StatefulWidget {
  final List<double> waveformData;
  final bool isRecording;
  final Color color;

  const WaveformPainter({
    super.key,
    required this.waveformData,
    this.isRecording = false,
    this.color = Colors.blue,
  });

  @override
  State<WaveformPainter> createState() => _WaveformPainterState();
}

class _WaveformPainterState extends State<WaveformPainter>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformPainter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _animationController.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: WaveformCustomPainter(
              waveformData: widget.waveformData,
              isRecording: widget.isRecording,
              color: widget.color,
              animationValue: _animation.value,
            ),
          );
        },
      ),
    );
  }
}

class WaveformCustomPainter extends CustomPainter {
  final List<double> waveformData;
  final bool isRecording;
  final Color color;
  final double animationValue;

  WaveformCustomPainter({
    required this.waveformData,
    required this.isRecording,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final centerY = size.height / 2;
    final stepWidth = size.width / (waveformData.length - 1);

    // Draw waveform
    Path path = Path();
    Path fillPath = Path();

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * stepWidth;
      final amplitude = waveformData[i] * (size.height / 2) * 0.8;
      final y = centerY + amplitude;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, centerY);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, centerY);
    fillPath.close();

    // Draw fill
    canvas.drawPath(fillPath, gradientPaint);

    // Draw waveform line
    canvas.drawPath(path, paint);

    // Draw recording indicator
    if (isRecording) {
      _drawRecordingIndicator(canvas, size);
    }
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;

    final centerY = size.height / 2;

    // Draw center line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // Draw placeholder waveform
    for (int i = 0; i < 50; i++) {
      final x = (i / 50) * size.width;
      final amplitude = math.sin(i * 0.3) * 20;
      final y = centerY + amplitude;

      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  void _drawRecordingIndicator(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withValues(alpha: 0.8 + 0.2 * math.sin(animationValue * math.pi * 2))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width - 30, 30),
      8,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}