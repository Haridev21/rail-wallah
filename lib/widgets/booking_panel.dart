// lib/widgets/booking_panel.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';

class BookingPanel extends StatefulWidget {
  final Set<String> selectedSeats;
  final Animation<double> animation;
  final VoidCallback onConfirm;

  const BookingPanel({
    super.key,
    required this.selectedSeats,
    required this.animation,
    required this.onConfirm,
  });

  @override
  State<BookingPanel> createState() => _BookingPanelState();
}

class _BookingPanelState extends State<BookingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seats = widget.selectedSeats.toList()..sort();
    final total = seats.length * kPricePerSeat;

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (ctx, child) {
        final animValue = widget.animation.value.clamp(0.0, 1.0);
        final h = animValue * 120.0;
        return Container(
          height: h,
          decoration: const BoxDecoration(
            color: kCoachBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border(top: BorderSide(color: kCoachBorder, width: 1)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Opacity(
            opacity: animValue,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: seats.map((s) {
                              final parts = s.split(':');
                              final label = '${parts[0]}·${parts[1]}';
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: kSelectedBg.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: kSelectedBg,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: GoogleFonts.inter(
                                    color: kTextPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹$total',
                        style: GoogleFonts.sora(
                          color: kTextPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildConfirmButton(),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: widget.onConfirm,
      child: AnimatedBuilder(
        animation: _shimmerAnim,
        builder: (ctx, child) => Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'CONFIRM BOOKING',
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(_shimmerAnim.value * 400, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.14),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
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
}
