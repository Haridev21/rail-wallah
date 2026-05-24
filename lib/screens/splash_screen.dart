import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

// ── Color Palette ────────────────────────────────────────────
const Color kBackground = Color(0xFF0D0D0D);
const Color kCrimson = Color(0xFF7B1A2E);
const Color kGold = Color(0xFFC9933A);
const Color kTrackColor = Color(0xFFC9933A);
const Color kWhite = Color(0xFFFFFFFF);

// ── Entry Point ──────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────
  late final AnimationController _trackCtrl; // Phase 1
  late final AnimationController _logoCtrl; // Phase 2
  late final AnimationController _steamCtrl; // Phase 3
  late final AnimationController _taglineCtrl; // Phase 4
  late final AnimationController _exitCtrl; // Phase 5
  late final AnimationController _bgCtrl; // Background topographic pan
  late final AnimationController _pulseCtrl; // Gold ring pulse

  // ── Track draw ───────────────────────────────────────────
  late final Animation<double> _trackProgress;

  // ── Logo ─────────────────────────────────────────────────
  late final Animation<double> _logoSlide;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoBounce;

  // ── Pulse ring ───────────────────────────────────────────
  late final Animation<double> _pulseRadius;
  late final Animation<double> _pulseOpacity;

  // ── Steam ────────────────────────────────────────────────
  late final Animation<double> _steamProgress;

  // ── Tagline ──────────────────────────────────────────────
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineSlide;

  // ── Exit ─────────────────────────────────────────────────
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  // ── Background pan ───────────────────────────────────────
  late final Animation<Offset> _bgOffset;

  @override
  void initState() {
    super.initState();

    // Background slow pan (looping)
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _bgOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.15, 0.1),
    ).animate(_bgCtrl);

    // Phase 1 — Track Reveal (0.0 → 1.5s)
    _trackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _trackProgress = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _trackCtrl, curve: Curves.easeOut));

    // Phase 2 — Logo Entrance (1.2 → 3.5s)
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _logoSlide = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _logoBounce =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.08,
              end: 1.0,
            ).chain(CurveTween(curve: const ElasticOutCurve(0.6))),
            weight: 2,
          ),
        ]).animate(
          CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.55, 1.0)),
        );

    // Pulse ring — fires after logo lands
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseRadius = Tween<double>(
      begin: 90,
      end: 220,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.85,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    // Phase 3 — Steam (3.5 → 5.5s)
    _steamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _steamProgress = Tween<double>(begin: 0, end: 1).animate(_steamCtrl);

    // Phase 4 — Tagline (4.5 → 6.0s)
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _taglineOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn));
    _taglineSlide = Tween<double>(
      begin: 15,
      end: 0,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));

    // Phase 5 — Exit (6.5 → 8.0s)
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _exitScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1 (0.0 - 1.5s)
    await Future.delayed(Duration.zero);
    _trackCtrl.forward();

    // Phase 2 (Entrance starts at 1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    _logoCtrl.forward();

    // Pulse ring fires on logo land (~3.5s total)
    await Future.delayed(const Duration(milliseconds: 2300));
    _pulseCtrl.forward();

    // Phase 3 (Steam starts at 3.5s)
    await Future.delayed(const Duration(milliseconds: 1000));
    _steamCtrl.forward();

    // Phase 4 (Tagline starts at 4.5s)
    await Future.delayed(const Duration(milliseconds: 1000));
    _taglineCtrl.forward();

    // Phase 5 (Exit starts at 6.5s)
    await Future.delayed(const Duration(milliseconds: 2000));
    _exitCtrl.forward();

    // Navigate at 8 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _trackCtrl.dispose();
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _steamCtrl.dispose();
    _taglineCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgCtrl,
          _trackCtrl,
          _logoCtrl,
          _pulseCtrl,
          _steamCtrl,
          _taglineCtrl,
          _exitCtrl,
        ]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Layer 1: Dark background ──────────────────
              Container(color: kBackground),

              // ── Layer 2: Topographic pattern (slow pan) ───
              ClipRect(
                child: CustomPaint(
                  size: size,
                  painter: TopographicPainter(
                    offset: _bgOffset.value,
                    opacity: 0.08,
                  ),
                ),
              ),

              // ── Layer 3: Radial crimson glow ──────────────
              Center(
                child: Container(
                  width: size.width * 0.85,
                  height: size.width * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kCrimson.withValues(alpha: 0.30 * _logoOpacity.value),
                        kCrimson.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Layer 4: Railway tracks ───────────────────
              CustomPaint(
                size: size,
                painter: RailTrackPainter(
                  progress: _trackProgress.value,
                  screenSize: size,
                ),
              ),

              // ── Layer 5: Gold pulse ring ──────────────────
              if (_pulseCtrl.value > 0)
                Center(
                  child: CustomPaint(
                    size: size,
                    painter: PulseRingPainter(
                      radius: _pulseRadius.value,
                      opacity: _pulseOpacity.value,
                    ),
                  ),
                ),

              // ── Layer 6: Logo + Steam + Tagline ──────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with bounce & slide
                    Transform.translate(
                      offset: Offset(0, _logoSlide.value),
                      child: Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: _logoBounce.value,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              // Steam particles above logo
                              if (_steamCtrl.value > 0)
                                Positioned(
                                  top: -60,
                                  left: -20,
                                  child: SizedBox(
                                    width: 220,
                                    height: 70,
                                    child: CustomPaint(
                                      painter: SteamPainter(
                                        progress: _steamProgress.value,
                                      ),
                                    ),
                                  ),
                                ),

                              // Logo image
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kCrimson.withValues(alpha: 0.5),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: kGold.withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _LogoFallback(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Tagline
                    Transform.translate(
                      offset: Offset(0, _taglineSlide.value),
                      child: Opacity(
                        opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                        child: Text(
                          'Your Journey, Our Passion',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 3.0,
                            color: kGold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Layer 7: Exit white flash overlay ─────────
              if (_exitCtrl.value > 0)
                Opacity(
                  opacity: (_exitOpacity.value * _exitScale.value).clamp(
                    0.0,
                    1.0,
                  ),
                  child: Transform.scale(
                    scale: _exitScale.value,
                    child: Container(color: kWhite),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// RailTrackPainter
// Draws two converging railway tracks from bottom to center.
// ============================================================
class RailTrackPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Size screenSize;

  const RailTrackPainter({required this.progress, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final w = size.width;
    final h = size.height;

    // Vanishing point = vertical center of screen
    final vp = Offset(w / 2, h * 0.5);

    // Track bottom spread
    const spread = 55.0;
    final leftBottom = Offset(w / 2 - spread, h);
    final rightBottom = Offset(w / 2 + spread, h);

    // Paint for rails
    final railPaint = Paint()
      ..color = kTrackColor.withValues(alpha: 0.60)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Paint for ties (cross-ties / sleepers)
    final tiePaint = Paint()
      ..color = kTrackColor.withValues(alpha: 0.30)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Animated endpoints (progress controls how far tracks extend upward)
    final leftCurrent = Offset.lerp(leftBottom, vp, progress)!;
    final rightCurrent = Offset.lerp(rightBottom, vp, progress)!;

    // Draw left rail
    canvas.drawLine(leftBottom, leftCurrent, railPaint);
    // Draw right rail
    canvas.drawLine(rightBottom, rightCurrent, railPaint);

    // Draw cross-ties
    const tieCount = 14;
    for (int i = 0; i < tieCount; i++) {
      final t = i / (tieCount - 1);
      if (t > progress) break;

      final tieT = t / progress.clamp(0.001, 1.0);
      final leftPt = Offset.lerp(leftBottom, leftCurrent, tieT)!;
      final rightPt = Offset.lerp(rightBottom, rightCurrent, tieT)!;

      // Fade ties near vanishing point
      final fadeAlpha = (1.0 - t) * 0.4;
      canvas.drawLine(
        leftPt,
        rightPt,
        tiePaint..color = kTrackColor.withValues(alpha: fadeAlpha),
      );
    }
  }

  @override
  bool shouldRepaint(RailTrackPainter old) => old.progress != progress;
}

// ============================================================
// PulseRingPainter
// Animated expanding gold ring that fades out.
// ============================================================
class PulseRingPainter extends CustomPainter {
  final double radius;
  final double opacity;

  const PulseRingPainter({required this.radius, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = kGold.withValues(alpha: opacity)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(PulseRingPainter old) =>
      old.radius != radius || old.opacity != opacity;
}

// ============================================================
// SteamPainter
// 8 staggered puffs drifting upward from the locomotive.
// ============================================================
class SteamPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0

  const SteamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const puffCount = 8;
    final rng = math.Random(42); // deterministic seed for consistent layout

    for (int i = 0; i < puffCount; i++) {
      // Each puff is staggered by 100ms equivalent in progress (1.0 / 800ms * 100ms)
      final stagger = i * 0.10;
      final local = ((progress - stagger) / (1.0 - stagger)).clamp(0.0, 1.0);
      if (local <= 0) continue;

      // Position: start near top-center of logo, drift up-left
      final startX = size.width * 0.55 + rng.nextDouble() * 30 - 15;
      final startY = size.height * 0.9;
      final driftX = startX - local * (15 + rng.nextDouble() * 20);
      final driftY =
          startY - local * (size.height * 0.85 + rng.nextDouble() * 20);

      // Scale: 0.3 → 1.5
      final scale = 0.3 + local * 1.2;
      final radius = (8 + rng.nextDouble() * 6) * scale;

      // Opacity: rise then fade
      final opacity = local < 0.5 ? local * 2 * 0.55 : (1.0 - local) * 2 * 0.55;

      final paint = Paint()
        ..color = kWhite.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(driftX, driftY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(SteamPainter old) => old.progress != progress;
}

// ============================================================
// TopographicPainter
// Slowly panning topo map pattern — thin lines, very low opacity.
// ============================================================
class TopographicPainter extends CustomPainter {
  final Offset offset;
  final double opacity;

  const TopographicPainter({required this.offset, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kWhite.withValues(alpha: opacity)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    final dx = offset.dx * size.width;
    final dy = offset.dy * size.height;

    // Concentric oval contours — organic topographic feel
    const lineCount = 18;
    for (int i = 0; i < lineCount; i++) {
      final t = i / lineCount;
      final rx = size.width * (0.15 + t * 0.65) + dx;
      final ry = size.height * (0.08 + t * 0.45) + dy;
      final cx = size.width * 0.5 + math.sin(t * math.pi) * 30;
      final cy = size.height * 0.45 + math.cos(t * 1.8) * 20;

      final path = Path()
        ..addOval(
          Rect.fromCenter(center: Offset(cx, cy), width: rx, height: ry),
        );
      canvas.drawPath(path, paint);
    }

    // A second offset set for density
    for (int i = 0; i < lineCount ~/ 2; i++) {
      final t = i / (lineCount / 2);
      final rx = size.width * (0.3 + t * 0.55) - dx * 0.5;
      final ry = size.height * (0.12 + t * 0.35) - dy * 0.5;
      final cx = size.width * 0.52 + math.cos(t * math.pi) * 50;
      final cy = size.height * 0.55 + math.sin(t * 2.1) * 30;

      final path = Path()
        ..addOval(
          Rect.fromCenter(center: Offset(cx, cy), width: rx, height: ry),
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(TopographicPainter old) => old.offset != offset;
}

// ============================================================
// _LogoFallback
// Rendered when logo asset is missing — matches brand identity.
// ============================================================
class _LogoFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: kCrimson),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.train_rounded, color: kWhite, size: 64),
          const SizedBox(height: 6),
          Text(
            'RAIL-WALLAH',
            style: GoogleFonts.oswald(
              color: kWhite,
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
