import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CosmicBackground - Background vũ trụ với hiệu ứng động smooth
///
/// Features:
/// - Gradient vũ trụ đa màu
/// - Static stars với twinkle effect
/// - Shooting stars (sao băng rơi)
/// - Smooth subtle nebula
class CosmicBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final int starCount;
  final bool animated;

  const CosmicBackground({
    super.key,
    required this.child,
    this.gradientColors,
    this.starCount = 150,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          const Color(0xFF0A0E27), // Deep space blue
          const Color(0xFF1A1A3E), // Dark purple
          const Color(0xFF2D1B3D), // Purple nebula
          const Color(0xFF0D1F2D), // Deep blue
        ];

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),

        // Subtle animated nebula
        if (animated)
          const Positioned.fill(
            child: SmoothNebula(),
          ),

        // Twinkling stars
        if (animated)
          const Positioned.fill(
            child: TwinklingStars(),
          ),

        // Shooting stars
        if (animated)
          const Positioned.fill(
            child: ShootingStars(),
          ),

        // Subtle vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.4),
              ],
              stops: const [0.0, 0.75, 1.0],
            ),
          ),
        ),

        // Child content
        child,
      ],
    );
  }
}

/// TwinklingStars - Ngôi sao lấp lánh nhẹ
class TwinklingStars extends StatefulWidget {
  const TwinklingStars({super.key});

  @override
  State<TwinklingStars> createState() => _TwinklingStarsState();
}

class _TwinklingStarsState extends State<TwinklingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: TwinklePainter(animationValue: _controller.value),
        );
      },
    );
  }
}

/// TwinklePainter - Vẽ hiệu ứng lấp lánh
class TwinklePainter extends CustomPainter {
  final double animationValue;
  final math.Random _random = math.Random(123);
  static final List<Offset> _starPositions = [];

  TwinklePainter({required this.animationValue}) {
    // Generate positions once
    if (_starPositions.isEmpty) {
      for (int i = 0; i < 30; i++) {
        _starPositions.add(
          Offset(_random.nextDouble(), _random.nextDouble()),
        );
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _starPositions.length; i++) {
      final pos = _starPositions[i];
      final x = pos.dx * size.width;
      final y = pos.dy * size.height;

      // Smooth sine wave twinkle
      final phase = (i / _starPositions.length) * 2 * math.pi;
      final twinkle = (math.sin(animationValue * 2 * math.pi + phase) + 1) / 2;
      final opacity = 0.1 + twinkle * 0.5;

      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(TwinklePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// ShootingStars - Sao băng rơi
class ShootingStars extends StatefulWidget {
  const ShootingStars({super.key});

  @override
  State<ShootingStars> createState() => _ShootingStarsState();
}

class _ShootingStarsState extends State<ShootingStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ShootingStar> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    _controller.addListener(() {
      // Tạo sao băng mới ngẫu nhiên (khoảng 1 cứ 3-5 giây)
      if (_random.nextDouble() < 0.008) {
        setState(() {
          _stars.add(ShootingStar(
            startX: _random.nextDouble(),
            startY: _random.nextDouble() * 0.5, // Chỉ ở nửa trên
            speed: 0.4 + _random.nextDouble() * 0.4,
            angle: math.pi / 6 + _random.nextDouble() * math.pi / 12,
            brightness: 0.6 + _random.nextDouble() * 0.4,
          ));
        });
      }

      // Xóa sao băng đã rơi xong
      setState(() {
        _stars.removeWhere((star) => star.progress > 1.0);
      });

      // Update progress
      for (var star in _stars) {
        star.progress += 0.012 * star.speed;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShootingStarsPainter(stars: _stars),
    );
  }
}

/// ShootingStar - Data class cho sao băng
class ShootingStar {
  final double startX;
  final double startY;
  final double speed;
  final double angle;
  final double brightness;
  double progress = 0.0;

  ShootingStar({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.angle,
    required this.brightness,
  });
}

/// ShootingStarsPainter - Vẽ sao băng với đuôi mượt mà
class ShootingStarsPainter extends CustomPainter {
  final List<ShootingStar> stars;

  ShootingStarsPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final currentX = star.startX * size.width +
          math.cos(star.angle) * star.progress * size.width * 0.4;
      final currentY = star.startY * size.height +
          math.sin(star.angle) * star.progress * size.height * 0.4;

      // Fade in/out effect
      double opacity;
      if (star.progress < 0.1) {
        opacity = star.progress / 0.1;
      } else if (star.progress > 0.8) {
        opacity = (1.0 - star.progress) / 0.2;
      } else {
        opacity = 1.0;
      }
      opacity *= star.brightness;

      // Vẽ đuôi sao băng theo quỹ đạo (multiple segments cho mượt)
      final segments = 10;
      
      for (int i = 0; i < segments; i++) {
        final t = i / segments;
        final segmentProgress = star.progress - (t * 0.15); // Độ trễ của đuôi
        
        if (segmentProgress < 0) continue;
        
        final x = star.startX * size.width +
            math.cos(star.angle) * segmentProgress * size.width * 0.4;
        final y = star.startY * size.height +
            math.sin(star.angle) * segmentProgress * size.height * 0.4;
        
        // Opacity giảm dần từ đầu đến đuôi
        final segmentOpacity = opacity * (1.0 - t);
        
        // Vẽ từng đoạn với glow effect
        final glowPaint = Paint()
          ..color = Colors.blue.withValues(alpha: segmentOpacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), 3.0 * (1.0 - t * 0.5), glowPaint);
        
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: segmentOpacity * 0.9)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), 1.5 * (1.0 - t * 0.5), corePaint);
      }

      // Vẽ đầu sao băng sáng nhất với glow mạnh
      final headGlowPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), 5.0, headGlowPaint);
      
      final headGlowPaint2 = Paint()
        ..color = Colors.blue.withValues(alpha: opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), 4.0, headGlowPaint2);

      final headCorePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(currentX, currentY), 2.5, headCorePaint);
    }
  }

  @override
  bool shouldRepaint(ShootingStarsPainter oldDelegate) => true;
}

/// SmoothNebula - Nebula mượt mà, chuyển động rất nhẹ
class SmoothNebula extends StatefulWidget {
  const SmoothNebula({super.key});

  @override
  State<SmoothNebula> createState() => _SmoothNebulaState();
}

class _SmoothNebulaState extends State<SmoothNebula>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45), // Rất chậm, smooth
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SmoothNebulaPainter(
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

/// SmoothNebulaPainter - Vẽ nebula mượt
class SmoothNebulaPainter extends CustomPainter {
  final double animationValue;

  SmoothNebulaPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    // Nebula cloud 1 (purple) - Di chuyển rất nhẹ
    final offset1 = Offset(
      size.width * 0.2 + math.sin(animationValue * 2 * math.pi) * 8,
      size.height * 0.3 + math.cos(animationValue * 2 * math.pi) * 8,
    );
    paint.color = const Color(0xFF6B2D9E).withValues(alpha: 0.06);
    canvas.drawCircle(offset1, 220, paint);

    // Nebula cloud 2 (cyan) - Di chuyển ngược chiều
    final offset2 = Offset(
      size.width * 0.7 + math.cos(animationValue * 2 * math.pi) * 12,
      size.height * 0.6 + math.sin(animationValue * 2 * math.pi) * 12,
    );
    paint.color = const Color(0xFF00D4FF).withValues(alpha: 0.05);
    canvas.drawCircle(offset2, 240, paint);

    // Nebula cloud 3 (pink) - Nhỏ hơn
    final offset3 = Offset(
      size.width * 0.5 + math.sin(animationValue * 2 * math.pi + 1) * 10,
      size.height * 0.15 + math.cos(animationValue * 2 * math.pi + 1) * 10,
    );
    paint.color = const Color(0xFFFF00AA).withValues(alpha: 0.03);
    canvas.drawCircle(offset3, 170, paint);
  }

  @override
  bool shouldRepaint(SmoothNebulaPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// SimpleGradientBackground - Background gradient đơn giản (không animation)
/// Dùng cho các screen cần performance cao hơn
class SimpleGradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const SimpleGradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ??
        [
          const Color(0xFF0A0E27),
          const Color(0xFF1A1A3E),
          const Color(0xFF0D1F2D),
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: child,
    );
  }
}

/// EnergyGridBackground - Background với grid pattern năng lượng
class EnergyGridBackground extends StatelessWidget {
  final Widget child;
  final Color gridColor;
  final double gridSpacing;

  const EnergyGridBackground({
    super.key,
    required this.child,
    this.gridColor = const Color(0xFF00D4FF),
    this.gridSpacing = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: const Color(0xFF0A0E27)),

        // Grid overlay
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(
              color: gridColor,
              spacing: gridSpacing,
            ),
          ),
        ),

        // Fade overlay (để grid không quá chói)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0E27).withValues(alpha: 0.7),
                const Color(0xFF0A0E27).withValues(alpha: 0.9),
              ],
            ),
          ),
        ),

        child,
      ],
    );
  }
}

/// GridPainter - Vẽ grid pattern
class GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
