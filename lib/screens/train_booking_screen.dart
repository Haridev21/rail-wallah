// lib/screens/train_booking_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../models/coach_config.dart';
import '../models/seat_data.dart';
import '../models/train_info.dart';
import '../widgets/coach_layout.dart';
import '../widgets/coach_tile.dart';
import '../widgets/booking_panel.dart';
import '../widgets/success_bottom_sheet.dart';

class _TrainBookingUiState {
  const _TrainBookingUiState({
    this.selectedCoachIndex = 0,
    this.selectedSeats = const <String>{},
  });

  final int selectedCoachIndex;
  final Set<String> selectedSeats;

  _TrainBookingUiState copyWith({
    int? selectedCoachIndex,
    Set<String>? selectedSeats,
  }) {
    return _TrainBookingUiState(
      selectedCoachIndex: selectedCoachIndex ?? this.selectedCoachIndex,
      selectedSeats: selectedSeats ?? this.selectedSeats,
    );
  }
}

class _TrainBookingUiNotifier extends StateNotifier<_TrainBookingUiState> {
  _TrainBookingUiNotifier() : super(const _TrainBookingUiState());

  void setSelectedCoachIndex(int index) {
    state = state.copyWith(selectedCoachIndex: index);
  }

  bool toggleSeat(String key) {
    final next = <String>{...state.selectedSeats};
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = state.copyWith(selectedSeats: next);
    return state.selectedSeats.isEmpty;
  }

  bool addSeat(String key) {
    final next = <String>{...state.selectedSeats}..add(key);
    state = state.copyWith(selectedSeats: next);
    return state.selectedSeats.isEmpty;
  }

  void clearSeats() {
    state = state.copyWith(selectedSeats: <String>{});
  }
}

final _trainBookingUiProvider =
    StateNotifierProvider.autoDispose<
      _TrainBookingUiNotifier,
      _TrainBookingUiState
    >((ref) => _TrainBookingUiNotifier());

class TrainBookingScreen extends ConsumerStatefulWidget {
  final TrainInfo trainInfo;
  const TrainBookingScreen({super.key, required this.trainInfo});

  @override
  ConsumerState<TrainBookingScreen> createState() => _TrainBookingScreenState();
}

class _TrainBookingScreenState extends ConsumerState<TrainBookingScreen>
    with TickerProviderStateMixin {
  final Map<String, Map<String, SeatData>> coachSeatMaps = {};

  late AnimationController _panelCtrl;
  late Animation<double> _panelAnim;

  static const List<String> _letters = ['A', 'B', 'C', 'D'];
  static const List<String> _lastLetters = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _generateAllSeats();
    int initialIndex = widget.trainInfo.coaches.indexWhere((c) => c.isBookable);
    if (initialIndex == -1) initialIndex = 0;
    ref
        .read(_trainBookingUiProvider.notifier)
        .setSelectedCoachIndex(initialIndex);

    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _panelAnim = CurvedAnimation(
      parent: _panelCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  void _generateAllSeats() {
    final rng = Random(42);
    for (final coach in widget.trainInfo.coaches) {
      if (!coach.isBookable) continue;
      final map = <String, SeatData>{};
      for (int row = 1; row <= coach.rows; row++) {
        for (final l in _letters) {
          map['$row$l'] = SeatData(id: '$row$l', status: _randomStatus(rng));
        }
      }
      if (coach.hasLastRow5) {
        final last = coach.rows + 1;
        for (final l in _lastLetters) {
          map['$last$l'] = SeatData(id: '$last$l', status: _randomStatus(rng));
        }
      }
      coachSeatMaps[coach.label] = map;
    }
  }

  SeatStatus _randomStatus(Random rng) {
    final v = rng.nextDouble();
    if (v < 0.60) return SeatStatus.available;
    if (v < 0.85) return SeatStatus.booked;
    if (v < 0.95) return SeatStatus.ladies;
    return SeatStatus.premium;
  }

  CoachConfig get _currentCoach =>
      widget.trainInfo.coaches[ref
          .watch(_trainBookingUiProvider)
          .selectedCoachIndex];

  void _onSeatTap(String coachLabel, String seatId) {
    final ui = ref.read(_trainBookingUiProvider);
    final data = coachSeatMaps[coachLabel]![seatId]!;
    if (data.status == SeatStatus.booked) return;
    if (data.status == SeatStatus.ladies) {
      _showLadiesDialog(coachLabel, seatId);
      return;
    }
    final key = '$coachLabel:$seatId';
    final isEmpty = ref.read(_trainBookingUiProvider.notifier).toggleSeat(key);
    if (isEmpty) {
      _panelCtrl.reverse();
    } else if (ui.selectedSeats.isNotEmpty || !isEmpty) {
      _panelCtrl.forward();
    }
  }

  void _showLadiesDialog(String coachLabel, String seatId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCoachBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ladies Seat',
          style: GoogleFonts.sora(color: kTextPrimary, fontSize: 16),
        ),
        content: Text(
          'This seat is reserved for ladies. Do you still want to select it?',
          style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: kTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(_trainBookingUiProvider.notifier)
                  .addSeat('$coachLabel:$seatId');
              _panelCtrl.forward();
            },
            child: Text('Select', style: GoogleFonts.inter(color: kLadiesBdr)),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() {
    final selectedSeats = ref.read(_trainBookingUiProvider).selectedSeats;
    final pnr =
        'TK${widget.trainInfo.trainNo}${Random().nextInt(999999).toString().padLeft(6, '0')}';
    final seats = List<String>.from(selectedSeats);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SuccessBottomSheet(seats: seats, pnr: pnr),
    ).then((_) {
      ref.read(_trainBookingUiProvider.notifier).clearSeats();
      _panelCtrl.reverse();
    });
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSeats = ref.watch(_trainBookingUiProvider).selectedSeats;
    final info = widget.trainInfo;
    return Scaffold(
      backgroundColor: kBgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(info),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              _buildJourneyCard(info),
              const SizedBox(height: 8),
              _buildTrainMap(),
              const SizedBox(height: 4),
              _buildCoachInfoBar(),
              _buildLegendRow(),
              Expanded(
                child: _currentCoach.isBookable
                    ? CoachLayout(
                        key: ValueKey(_currentCoach.label),
                        coach: _currentCoach,
                        seatMap: coachSeatMaps[_currentCoach.label]!,
                        selectedSeats: selectedSeats,
                        onSeatTap: (id) => _onSeatTap(_currentCoach.label, id),
                      )
                    : _buildNonBookable(),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BookingPanel(
              selectedSeats: selectedSeats,
              animation: _panelAnim,
              onConfirm: _confirmBooking,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(TrainInfo info) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: kBgColor.withValues(alpha: 0.92),
          border: const Border(
            bottom: BorderSide(color: kCoachBorder, width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 8),
              _iconBtn(
                Icons.arrow_back_ios_new_rounded,
                () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${info.trainNo}  ·  ${info.trainName}',
                      style: GoogleFonts.sora(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${info.fromStnName} → ${info.toStnName}',
                      style: GoogleFonts.inter(
                        color: kTextSecondary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _iconBtn(Icons.share_rounded, () {}),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kCoachBorder,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kTextPrimary, size: 16),
      ),
    );
  }

  Widget _buildJourneyCard(TrainInfo info) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kCoachBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.fromStnName,
                    style: GoogleFonts.sora(
                      color: kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    info.departure,
                    style: GoogleFonts.inter(color: kAccent, fontSize: 11),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: kTextSecondary,
                    size: 16,
                  ),
                  Text(
                    '${widget.trainInfo.coaches.where((c) => c.isBookable).length} coaches',
                    style: GoogleFonts.inter(color: kRowNum, fontSize: 9),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    info.toStnName,
                    style: GoogleFonts.sora(
                      color: kTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                  Text(
                    info.arrival,
                    style: GoogleFonts.inter(color: kAccent, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainMap() {
    final selectedCoachIndex = ref
        .watch(_trainBookingUiProvider)
        .selectedCoachIndex;
    final coaches = widget.trainInfo.coaches;
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: coaches.length,
        itemBuilder: (context, i) {
          final coach = coaches[i];
          return CoachTile(
            coach: coach,
            isSelected: i == selectedCoachIndex,
            isFirst: i == 0,
            isLast: i == coaches.length - 1,
            availableCount:
                coachSeatMaps[coach.label]?.values
                    .where((s) => s.status == SeatStatus.available)
                    .length ??
                0,
            onTap: () => ref
                .read(_trainBookingUiProvider.notifier)
                .setSelectedCoachIndex(i),
          );
        },
      ),
    );
  }

  Widget _buildCoachInfoBar() {
    final coach = _currentCoach;
    final available =
        coachSeatMaps[coach.label]?.values
            .where((s) => s.status == SeatStatus.available)
            .length ??
        0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(coach.label),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: coach.accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: coach.accentColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: coach.accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  coach.label,
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                coach.typeName,
                style: GoogleFonts.sora(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (coach.isBookable) ...[
                Icon(
                  Icons.event_seat_rounded,
                  color: coach.accentColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$available / ${coach.totalSeats} avail.',
                  style: GoogleFonts.inter(color: kTextSecondary, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _chip(kAvailableBg, kAvailableBdr, 'Available'),
            _chip(kSelectedBg, kSelectedBg, 'Selected'),
            _chip(kBookedBg, kBookedBdr, 'Booked'),
            _chip(kLadiesBg, kLadiesBdr, 'Ladies'),
            _chip(kPremiumBg, kPremiumBdr, 'Premium'),
          ],
        ),
      ),
    );
  }

  Widget _chip(Color bg, Color border, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              color: kTextPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonBookable() {
    final coach = _currentCoach;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(coach.icon, color: coach.accentColor, size: 56),
          const SizedBox(height: 16),
          Text(
            coach.typeName,
            style: GoogleFonts.sora(
              color: kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This coach is not available for booking.',
            style: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
