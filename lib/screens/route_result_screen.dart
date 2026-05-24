import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_result.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A237E);
  static const primaryLight = Color(0xFF283593);
  static const backgroundColor = Color(0xFFF8F9FA);
}

const List<List<Color>> _segColors = [
  [Color(0xFF0277BD), Color(0xFF01579B)],
  [Color(0xFF00838F), Color(0xFF006064)],
  [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  [Color(0xFFD84315), Color(0xFFBF360C)],
  [Color(0xFF6A1B9A), Color(0xFF4A148C)],
  [Color(0xFF558B2F), Color(0xFF33691E)],
];

const Map<String, Color> _classColors = {
  '1A': Color(0xFF1565C0),
  '2A': Color(0xFF6A1B9A),
  '3A': Color(0xFFF57F17),
  '3E': Color(0xFFE65100),
  'EC': Color(0xFFC62828),
  'CC': Color(0xFF2E7D32),
  'SL': Color(0xFF546E7A),
  '2S': Color(0xFF37474F),
  'GN': Color(0xFF424242),
};



String _str(dynamic s, String key) {
  if (s is Map) return (s[key] ?? '').toString();
  try {
    return (s as dynamic).toJson()[key]?.toString() ?? '';
  } catch (_) {
    return '';
  }
}

int _int(dynamic s, String key) {
  if (s is Map) return (s[key] ?? 0) as int;
  try {
    return ((s as dynamic).toJson()[key] ?? 0) as int;
  } catch (_) {
    return 0;
  }
}

double _dbl(dynamic s, String key) {
  if (s is Map) return (s[key] ?? 0).toDouble();
  try {
    return ((s as dynamic).toJson()[key] ?? 0).toDouble();
  } catch (_) {
    return 0;
  }
}

bool _bool(dynamic s, String key) {
  if (s is Map) return s[key] == true;
  try {
    return (s as dynamic).toJson()[key] == true;
  } catch (_) {
    return false;
  }
}

List<String> _classList(dynamic s) {
  if (s is Map) {
    final v = s['classes'];
    if (v is List) return v.map((e) => e.toString()).toList();
  }
  return [];
}



class RouteResultScreen extends StatelessWidget {
  final RouteResult result;
  const RouteResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final segments = result.segments ?? [];
    final hasSegments = segments.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          

          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Route Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(right: -40, top: -40, child: _circle(160, 0.05)),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: _circle(120, 0.05),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  

                  _SummaryCard(result: result),
                  const SizedBox(height: 16),

                  
// ── All class fares row ────────────────────────────────
                  if (result.allClassFares != null &&
                      result.allClassFares!.isNotEmpty)
                    _AllFaresCard(
                      fares: result.allClassFares!,
                      selectedClass: result.fareClass ?? 'SL',
                    ),

                  
// ── Budget exceeded warning ────────────────────────────
                  if (result.budgetExceeded == true &&
                      result.budgetAlternative != null) ...[
                    const SizedBox(height: 12),
                    _BudgetAlternativeCard(
                      budget: result.budget ?? 0,
                      budgetGap: result.budgetGap ?? 0,
                      alt: result.budgetAlternative!,
                    ),
                  ],

                  const SizedBox(height: 24),

                  

                  Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        color: AppTheme.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Journey',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (hasSegments)
                        _pill(
                          '${segments.length} train${segments.length > 1 ? "s" : ""}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  

                  // seg[i].wait_minutes = wait at seg[i].from BEFORE boarding.
                  // The wait BETWEEN train[i] and train[i+1] is stored on
                  // seg[i+1].wait_minutes and happens at seg[i].to.
                  // So the connector reads from the NEXT segment, not current.
                  if (hasSegments)
                    ...List.generate(segments.length, (i) {
                      final seg = segments[i];
                      final isLast = i == segments.length - 1;
                      final nextSeg = isLast ? null : segments[i + 1];

                      return Column(
                        children: [
                          _SegmentCard(seg: seg, index: i, isLast: isLast),
                          if (!isLast && nextSeg != null)
                            _WaitConnector(
                              atStation: _str(seg, 'to'),
                              waitMinutes: _int(nextSeg, 'wait_minutes'),
                              waitStr: _str(nextSeg, 'wait_str'),
                              warning: _str(nextSeg, 'wait_warning'),
                              nextTrainNo: _str(nextSeg, 'train_no'),
                              nextTrainName: _str(nextSeg, 'train_name'),
                              nextDep: _str(nextSeg, 'dep_ampm').isNotEmpty
                                  ? _str(nextSeg, 'dep_ampm')
                                  : _str(nextSeg, 'dep_time'),
                            ),
                        ],
                      );
                    })
                  else
                    _LegacyPathView(result: result),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );

  static Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.primaryColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    ),
  );
}



class _SummaryCard extends StatelessWidget {
  final RouteResult result;
  const _SummaryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final segments = result.segments ?? [];
    final transfers = result.transfers ?? (segments.length - 1).clamp(0, 99);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // FROM → TO
          Row(
            children: [
              Expanded(child: _endpoint('FROM', result.source)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Expanded(
                child: _endpoint('TO', result.destination, alignEnd: true),
              ),
            ],
          ),

          // Day + time + date
          if (result.travelDay != null || result.startTime != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    [
                      if (result.travelDate != null &&
                          result.travelDate!.isNotEmpty)
                        result.travelDate!
                      else if (result.travelDay != null)
                        result.travelDay!,
                      if (result.startTime != null) 'After ${result.startTime}',
                    ].join('  ·  '),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 18),

          // Stats row 1
          Row(
            children: [
              Expanded(
                child: _stat(
                  Icons.access_time_rounded,
                  result.totalTime ?? '--',
                  'Total Time',
                ),
              ),
              _vDiv(),
              Expanded(
                child: _stat(
                  Icons.train_rounded,
                  result.travelTime ?? '--',
                  'Travel',
                ),
              ),
              _vDiv(),
              Expanded(
                child: _stat(
                  Icons.hourglass_bottom_rounded,
                  result.waitingTime ?? '--',
                  'Waiting',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stats row 2
          Row(
            children: [
              Expanded(
                child: _stat(
                  Icons.straighten_rounded,
                  '${result.totalDistance ?? result.distanceKm ?? 0} km',
                  'Distance',
                ),
              ),
              _vDiv(),
              Expanded(
                child: _stat(Icons.swap_horiz_rounded, '$transfers', 'Changes'),
              ),
              _vDiv(),
              Expanded(
                child: _stat(
                  Icons.location_on_rounded,
                  '${result.path?.length ?? 0}',
                  'Stops',
                ),
              ),
            ],
          ),

          // ── Fare highlight ─────────────────────────────────────────────
          if (result.fare != null && result.fare! > 0) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.currency_rupee, color: Colors.white, size: 24),
                Text(
                  '${result.fare}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    result.fareClass ?? 'SL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              result.fareBreakdown ?? '',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              'Estimated fare · IRCTC formula',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _endpoint(String label, String? name, {bool alignEnd = false}) =>
      Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name ?? '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          ),
        ],
      );

  Widget _stat(IconData icon, String value, String label) => Column(
    children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.75),
          fontSize: 10,
        ),
      ),
    ],
  );

  Widget _vDiv() => Container(
    width: 1,
    height: 44,
    color: Colors.white.withValues(alpha: 0.2),
  );
}



final _segmentExpandedProvider = StateProvider.family<bool, int>(
  (ref, index) => false,
);

class _SegmentCard extends ConsumerWidget {
  final dynamic seg;
  final int index;
  final bool isLast;
  const _SegmentCard({
    required this.seg,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(_segmentExpandedProvider(index));
    final s = seg;
    final colors = _segColors[index % _segColors.length];
    final trainNo = _str(s, 'train_no');
    final trainName = _str(s, 'train_name');
    final from = _str(s, 'from');
    final to = _str(s, 'to');
    final depAmpm = _str(s, 'dep_ampm').isNotEmpty
        ? _str(s, 'dep_ampm')
        : _str(s, 'dep_time');
    final arrAmpm = _str(s, 'arr_ampm').isNotEmpty
        ? _str(s, 'arr_ampm')
        : _str(s, 'arr_time');
    final travelStr = _str(s, 'travel_str');
    final distKm = _dbl(s, 'distance_km');
    final classes = _classList(s);
    final hasAc = _bool(s, 'has_ac');
    final overnight = _bool(s, 'overnight');
    final dayOff = _int(s, 'day_offset');

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.train_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Train $trainNo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (trainName.isNotEmpty)
                          Text(
                            trainName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (overnight) _badge('🌙 +${dayOff}d'),
                  if (hasAc) ...[const SizedBox(width: 6), _badge('AC')],
                ],
              ),
            ),

            // ── From / To with departure and arrival times ────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  

                  Column(
                    children: [
                      _dot(colors[0], large: true),
                      Container(
                        width: 3,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: colors,
                          ),
                        ),
                      ),
                      _dot(colors[1], large: false),
                    ],
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      children: [
                        // FROM row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                from,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (depAmpm.isNotEmpty && depAmpm != '--')
                              _timeChip(depAmpm, colors[0]),
                          ],
                        ),

                        const SizedBox(height: 52),

                        // TO row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                to,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (arrAmpm.isNotEmpty && arrAmpm != '--')
                              Row(
                                children: [
                                  _timeChip(arrAmpm, colors[1]),
                                  if (overnight) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${dayOff}d',
                                      style: TextStyle(
                                        color: colors[1],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            

            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors[0].withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors[0].withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(
                    Icons.access_time_rounded,
                    travelStr,
                    'Duration',
                    colors[0],
                  ),
                  _vDivColor(colors[0]),
                  _infoItem(
                    Icons.straighten_rounded,
                    '${distKm.toStringAsFixed(0)} km',
                    'Distance',
                    colors[0],
                  ),
                  if (classes.isNotEmpty) ...[
                    _vDivColor(colors[0]),
                    _infoItem(
                      Icons.airline_seat_recline_extra_rounded,
                      classes.take(3).join(' · '),
                      'Classes',
                      colors[0],
                    ),
                  ],
                ],
              ),
            ),

            

            if (classes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: classes.map((c) => _ClassChip(cls: c)).toList(),
                ),
              ),

            

            InkWell(
              onTap: () {
                ref.read(_segmentExpandedProvider(index).notifier).state =
                    !expanded;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[100]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      expanded ? 'Show less' : 'Journey details',
                      style: TextStyle(
                        color: colors[0],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colors[0],
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),



            if (expanded)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(
                      Icons.departure_board_rounded,
                      'Departure',
                      depAmpm.isNotEmpty ? depAmpm : '--',
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      Icons.flag_rounded,
                      'Arrival',
                      arrAmpm.isNotEmpty ? arrAmpm : '--',
                    ),
                    const SizedBox(height: 8),
                    _detailRow(Icons.train_rounded, 'Train Number', trainNo),
                    if (trainName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _detailRow(Icons.label_rounded, 'Train Name', trainName),
                    ],
                    if (overnight) ...[
                      const SizedBox(height: 8),
                      _detailRow(
                        Icons.nights_stay_rounded,
                        'Overnight',
                        'Arrives +$dayOff day${dayOff > 1 ? "s" : ""}',
                      ),
                    ],
                    // Fare for this segment
                    Builder(
                      builder: (_) {
                        final fare = _int(s, 'fare');
                        final cls = _str(s, 'fare_class');
                        if (fare <= 0) return const SizedBox.shrink();
                        return Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    size: 15,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Fare ($cls): Rs$fare',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_dbl(s, "distance_km").toStringAsFixed(0)} km',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    margin: const EdgeInsets.only(left: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _timeChip(String time, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      time,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
    ),
  );

  Widget _dot(Color color, {required bool large}) => Container(
    width: large ? 14 : 12,
    height: large ? 14 : 12,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    ),
  );

  Widget _infoItem(IconData icon, String value, String label, Color color) =>
      Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
        ],
      );

  Widget _vDivColor(Color color) =>
      Container(width: 1, height: 34, color: color.withValues(alpha: 0.2));

  Widget _detailRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, color: AppTheme.primaryColor, size: 16),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}



//
//  atStation   = seg[i].to          — station where passenger waits
//  waitMinutes = seg[i+1].wait_minutes — duration of the wait
//  waitStr     = seg[i+1].wait_str  — "2h 15m"
//  warning     = seg[i+1].wait_warning — "long" / "very_long" / ""
//  nextTrainNo = seg[i+1].train_no  — train to board next
//  nextDep     = seg[i+1].dep_ampm  — departure time of next train
//
class _WaitConnector extends StatelessWidget {
  final String atStation;
  final int waitMinutes;
  final String waitStr;
  final String warning;
  final String nextTrainNo;
  final String nextTrainName;
  final String nextDep;

  const _WaitConnector({
    required this.atStation,
    required this.waitMinutes,
    required this.waitStr,
    required this.warning,
    required this.nextTrainNo,
    required this.nextTrainName,
    required this.nextDep,
  });

  @override
  Widget build(BuildContext context) {
    final isVeryLong = warning == 'very_long';
    final isLong = warning == 'long';
    final hasWait = waitMinutes > 0;

    // Colour scheme based on severity
    final Color bg, border, iconColor, textColor;
    final IconData icon;

    if (isVeryLong) {
      bg = const Color(0xFFFFEBEE);
      border = const Color(0xFFEF9A9A);
      iconColor = const Color(0xFFC62828);
      textColor = const Color(0xFFB71C1C);
      icon = Icons.warning_amber_rounded;
    } else if (isLong) {
      bg = const Color(0xFFFFF3E0);
      border = const Color(0xFFFFCC80);
      iconColor = const Color(0xFFE65100);
      textColor = const Color(0xFFBF360C);
      icon = Icons.access_time_filled_rounded;
    } else {
      bg = const Color(0xFFF3F4F6);
      border = const Color(0xFFD1D5DB);
      iconColor = const Color(0xFF6B7280);
      textColor = const Color(0xFF374151);
      icon = Icons.swap_horiz_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),

                // Station label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change train at',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        atStation,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),



                if (hasWait)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_bottom_rounded,
                          color: iconColor,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          waitStr.isNotEmpty ? waitStr : '${waitMinutes}m',
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),



            if (nextTrainNo.isNotEmpty || nextDep.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.train_rounded, color: iconColor, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextTrainNo.isNotEmpty
                                ? 'Board Train $nextTrainNo'
                                : 'Board next train',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (nextTrainName.isNotEmpty)
                            Text(
                              nextTrainName,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (nextDep.isNotEmpty && nextDep != '--') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: iconColor,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Dep $nextDep',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],



            if (isVeryLong || isLong) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: iconColor,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isVeryLong
                            ? 'Very long wait — consider a bus or cab to avoid waiting'
                            : 'Long wait — grab food or rest near the station',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



class _ClassChip extends StatelessWidget {
  final String cls;
  const _ClassChip({required this.cls});

  @override
  Widget build(BuildContext context) {
    final color = _classColors[cls] ?? Colors.grey[600]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        cls,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}



class _AllFaresCard extends StatelessWidget {
  final Map<String, dynamic> fares;
  final String selectedClass;
  const _AllFaresCard({required this.fares, required this.selectedClass});

  @override
  Widget build(BuildContext context) {
    const order = ['GN', '2S', 'SL', '3E', 'CC', '3A', '2A', '1A'];
    final sorted = order.where((c) => fares.containsKey(c)).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Fare by Class',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sorted.map((c) {
              final isSel = c == selectedClass;
              final color = _classColors[c] ?? Colors.grey.shade600;
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? color.withValues(alpha: 0.15)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? color : Colors.grey[200]!,
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          c,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSel ? color : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs${fares[c]}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? color : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSel) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}



class _BudgetAlternativeCard extends StatelessWidget {
  final int budget;
  final int budgetGap;
  final Map<String, dynamic> alt;
  const _BudgetAlternativeCard({
    required this.budget,
    required this.budgetGap,
    required this.alt,
  });

  @override
  Widget build(BuildContext context) {
    final summary = (alt['summary'] ?? '').toString();
    final altFare = (alt['fare'] ?? 0) as int;
    final altCls = (alt['coach_class'] ?? '').toString();
    final savings = (alt['savings'] ?? 0) as int;
    final timeDiff = (alt['time_diff_str'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Exceeded',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Rs$budgetGap over your budget of Rs$budget',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: Colors.orange.shade100),
          const SizedBox(height: 12),

          // Suggestion box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.recommend, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Suggested Alternative',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Chips row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _chip('Rs$altFare', Colors.green),
                    _chip(altCls, Colors.blue),
                    if (timeDiff.isNotEmpty) _chip(timeDiff, Colors.purple),
                    if (savings > 0) _chip('Save Rs$savings', Colors.orange),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, MaterialColor color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.shade200),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color.shade700,
      ),
    ),
  );
}



class _LegacyPathView extends StatelessWidget {
  final RouteResult result;
  const _LegacyPathView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Path',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...?result.path?.map(
            (step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.station ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (step.train != null)
                    Text(
                      'Train ${step.train}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
