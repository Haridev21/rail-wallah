// lib/widgets/seat_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/seat_data.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

class SeatWidget extends StatefulWidget {
  final String seatId;
  final SeatData seatData;
  final bool isSelected;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seatId,
    required this.seatData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> with TickerProviderStateMixin {
  late AnimationController _tapCtrl;
  late Animation<double> _scaleAnim;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _tapCtrl, curve: Curves.easeOutCubic));

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 2,
      end: 8,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.4,
      end: 0.65,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.seatData.status == SeatStatus.booked) return;
    _tapCtrl.forward(from: 0);
    widget.onTap();
  }

  Color get _bgColor {
    if (widget.isSelected) return kSelectedBg;
    switch (widget.seatData.status) {
      case SeatStatus.available:
        return kAvailableBg;
      case SeatStatus.booked:
        return kBookedBg;
      case SeatStatus.ladies:
        return kLadiesBg;
      case SeatStatus.premium:
        return kPremiumBg;
    }
  }

  Color get _borderColor {
    if (widget.isSelected) return kSelectedBg;
    switch (widget.seatData.status) {
      case SeatStatus.available:
        return kAvailableBdr;
      case SeatStatus.booked:
        return kBookedBdr;
      case SeatStatus.ladies:
        return kLadiesBdr;
      case SeatStatus.premium:
        return kPremiumBdr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.seatData.status == SeatStatus.booked) {
      return AnimatedBuilder(
        animation: _pulseAnim,
        builder: (ctx, child) =>
            Opacity(opacity: _pulseAnim.value, child: _box(0)),
      );
    }
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnim, _glowAnim]),
        builder: (ctx, child) => Transform.scale(
          scale: _tapCtrl.isAnimating ? _scaleAnim.value : 1.0,
          child: _box(widget.isSelected ? _glowAnim.value : 0),
        ),
      ),
    );
  }

  Widget _box(double glow) {
    return Container(
      width: kSeatW,
      height: kSeatH,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _borderColor, width: 1.4),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: _borderColor.withValues(alpha: 0.6),
                  blurRadius: glow,
                  spreadRadius: glow * 0.3,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.seatId,
        style: GoogleFonts.inter(
          color: kTextPrimary,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
