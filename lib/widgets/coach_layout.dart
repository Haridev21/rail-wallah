// lib/widgets/coach_layout.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/coach_config.dart';
import '../models/seat_data.dart';
import '../constants/colors.dart';
import '../constants/dimensions.dart';
import 'seat_widget.dart';

class CoachLayout extends StatefulWidget {
  final CoachConfig coach;
  final Map<String, SeatData> seatMap;
  final Set<String> selectedSeats;
  final void Function(String seatId) onSeatTap;

  const CoachLayout({
    super.key,
    required this.coach,
    required this.seatMap,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  State<CoachLayout> createState() => _CoachLayoutState();
}

class _CoachLayoutState extends State<CoachLayout>
    with TickerProviderStateMixin {
  late List<AnimationController> _rowCtrl;
  late List<Animation<Offset>> _rowSlide;
  late List<Animation<double>> _rowFade;

  int get _totalRows => widget.coach.rows + (widget.coach.hasLastRow5 ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _rowCtrl = List.generate(
      _totalRows,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 480),
      ),
    );
    _rowSlide = _rowCtrl
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(-0.35, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();
    _rowFade = _rowCtrl
        .map(
          (c) => Tween<double>(
            begin: 0,
            end: 1,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    for (int i = 0; i < _totalRows; i++) {
      Future.delayed(Duration(milliseconds: i * 35), () {
        if (mounted) _rowCtrl[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _rowCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 130),
      child: Container(
        decoration: BoxDecoration(
          color: kCoachBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(36),
            topRight: Radius.circular(36),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: kCoachBorder, width: 2),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildFacilities(),
            const Divider(color: kCoachBorder, thickness: 1, height: 1),
            const SizedBox(height: 6),
            for (int row = 1; row <= widget.coach.rows; row++)
              SlideTransition(
                position: _rowSlide[row - 1],
                child: FadeTransition(
                  opacity: _rowFade[row - 1],
                  child: _buildRow(row),
                ),
              ),
            if (widget.coach.hasLastRow5) ...[
              const Divider(color: kCoachBorder, thickness: 1, height: 14),
              SlideTransition(
                position: _rowSlide[_totalRows - 1],
                child: FadeTransition(
                  opacity: _rowFade[_totalRows - 1],
                  child: _buildLastRow(),
                ),
              ),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
        gradient: LinearGradient(
          colors: [widget.coach.accentColor.withValues(alpha: 0.18), kCoachBg],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.train_rounded,
                color: widget.coach.accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'COACH ${widget.coach.label}  ·  ${widget.coach.typeName}',
                style: GoogleFonts.sora(
                  color: kTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
              (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 22,
                height: 11,
                decoration: BoxDecoration(
                  color: kCoachBorder,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: kAisle, width: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilities() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          _tag(Icons.wc_rounded, 'WC'),
          const SizedBox(width: 8),
          _tag(Icons.door_front_door_outlined, 'DOOR'),
          const Spacer(),
          _tag(Icons.kitchen_rounded, 'PANTRY'),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kAisle.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kAisle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kTextSecondary, size: 11),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              color: kTextSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(int rowNum) {
    final cl = widget.coach.label;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '$rowNum',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: kRowNum,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          for (final id in ['${rowNum}A', '${rowNum}B'])
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SeatWidget(
                key: ValueKey('$cl:$id'),
                seatId: id,
                seatData: widget.seatMap[id]!,
                isSelected: widget.selectedSeats.contains('$cl:$id'),
                onTap: () => widget.onSeatTap(id),
              ),
            ),
          SizedBox(
            width: 20,
            child: Center(
              child: CustomPaint(
                size: const Size(1, kSeatH),
                painter: _DashedLine(),
              ),
            ),
          ),
          for (final id in ['${rowNum}C', '${rowNum}D'])
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: SeatWidget(
                key: ValueKey('$cl:$id'),
                seatId: id,
                seatData: widget.seatMap[id]!,
                isSelected: widget.selectedSeats.contains('$cl:$id'),
                onTap: () => widget.onSeatTap(id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLastRow() {
    final cl = widget.coach.label;
    final last = widget.coach.rows + 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 3),
            child: Text(
              'Last Row (5 seats)',
              style: GoogleFonts.inter(color: kTextSecondary, fontSize: 9),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '$last',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: kRowNum,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              for (final letter in ['A', 'B', 'C', 'D', 'E'])
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SeatWidget(
                    key: ValueKey('$cl:$last$letter'),
                    seatId: '$last$letter',
                    seatData: widget.seatMap['$last$letter']!,
                    isSelected: widget.selectedSeats.contains(
                      '$cl:$last$letter',
                    ),
                    onTap: () => widget.onSeatTap('$last$letter'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kAisle
      ..strokeWidth = 1.2;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 4), paint);
      y += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
