// lib/widgets/success_bottom_sheet.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class SuccessBottomSheet extends StatefulWidget {
  final List<String> seats;
  final String pnr;

  const SuccessBottomSheet({super.key, required this.seats, required this.pnr});

  @override
  State<SuccessBottomSheet> createState() => _SuccessBottomSheetState();
}

class _SuccessBottomSheetState extends State<SuccessBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late Animation<double> _checkAnim;
  late AnimationController _confettiCtrl;
  late Animation<double> _confettiAnim;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _Particle(
          angle: _rng.nextDouble() * 2 * pi,
          distance: 60 + _rng.nextDouble() * 80,
          color: [
            kAccent,
            kLadiesBdr,
            kPremiumBdr,
            Colors.amber,
            Colors.orange,
          ][_rng.nextInt(5)],
          size: 4 + _rng.nextDouble() * 5,
        ),
      );
    }
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _checkAnim = CurvedAnimation(
      parent: _checkCtrl,
      curve: Curves.easeOutCubic,
    );

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confettiAnim = CurvedAnimation(
      parent: _confettiCtrl,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(
      const Duration(milliseconds: 100),
      () => _checkCtrl.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 500),
      () => _confettiCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.seats
        .map((s) {
          final p = s.split(':');
          return '${p[0]}·${p[1]}';
        })
        .join(', ');

    return Container(
      decoration: const BoxDecoration(
        color: kCoachBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kAisle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _confettiAnim,
                  builder: (ctx, child) => SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _confettiAnim.value,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _checkAnim,
                  builder: (ctx, child) => CustomPaint(
                    size: const Size(90, 90),
                    painter: _CheckmarkPainter(progress: _checkAnim.value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Booking Confirmed!',
            style: GoogleFonts.sora(
              color: kTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            labels,
            style: GoogleFonts.inter(color: kTextSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kPremiumBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kPremiumBdr),
            ),
            child: Text(
              'PNR: ${widget.pnr}',
              style: GoogleFonts.sora(
                color: kPremiumBdr,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: kCoachBorder,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kCoachBorder, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.sora(
                        color: kTextSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View Ticket',
                      style: GoogleFonts.sora(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  const _CheckmarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final cp = (progress * 1.5).clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * cp,
      false,
      Paint()
        ..color = kPremiumBdr
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0.6) {
      final tp = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
      final p1 = Offset(center.dx - radius * 0.4, center.dy);
      final p2 = Offset(center.dx - radius * 0.05, center.dy + radius * 0.35);
      final p3 = Offset(center.dx + radius * 0.45, center.dy - radius * 0.3);
      final seg1 = (p2 - p1).distance;
      final seg2 = (p3 - p2).distance;
      final drawn = tp * (seg1 + seg2);
      final path = Path()..moveTo(p1.dx, p1.dy);
      if (drawn <= seg1) {
        final t = drawn / seg1;
        path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
      } else {
        path.lineTo(p2.dx, p2.dy);
        final t = (drawn - seg1) / seg2;
        path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = kPremiumBdr
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter old) =>
      old.progress != progress;
}

class _Particle {
  final double angle, distance, size;
  final Color color;
  const _Particle({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final dist = p.distance * progress;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(
          center.dx + cos(p.angle) * dist,
          center.dy + sin(p.angle) * dist,
        ),
        p.size * (1 - progress * 0.5),
        Paint()
          ..color = p.color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
