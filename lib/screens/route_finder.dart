import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../models/route_result.dart';
import '../services/path_api.dart';
import 'route_result_screen.dart';

class AppTheme {
  static const primaryColor = Color(0xFF1A237E);
  static const primaryLight = Color(0xFF283593);
  static const backgroundColor = Color(0xFFF8F9FA);
  static const accentGreen = Color(0xFF4CAF50);
  static const accentRed = Color(0xFFE53935);
}

// ── Loading quotes — shown while fetching route ───────────────────────────────
const List<String> _loadingQuotes = [
  "Scanning 210,000+ rail connections...",
  "Checking running days across India...",
  "Calculating transfer waiting times...",
  "Finding the fastest path through the network...",
  "Comparing routes via major junctions...",
  "Almost there — crunching the final hops...",
  "Checking AC and Sleeper availability...",
  "Mapping your journey across the subcontinent...",
  "Running Dijkstra through 10,000+ stations...",
  "One moment — optimising for minimum wait time...",
];

class _RouteFinderState {
  const _RouteFinderState({
    this.stations = const [],
    this.sourceStation,
    this.destinationStation,
    required this.selectedDate,
    required this.selectedTime,
    this.preference = 'any',
    this.coachClass = 'SL',
    this.useBudget = false,
  });

  final List<String> stations;
  final String? sourceStation;
  final String? destinationStation;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String preference;
  final String coachClass;
  final bool useBudget;

  factory _RouteFinderState.initial() => _RouteFinderState(
    selectedDate: DateTime.now(),
    selectedTime: const TimeOfDay(hour: 8, minute: 0),
  );

  _RouteFinderState copyWith({
    List<String>? stations,
    String? sourceStation,
    bool clearSource = false,
    String? destinationStation,
    bool clearDestination = false,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? preference,
    String? coachClass,
    bool? useBudget,
  }) {
    return _RouteFinderState(
      stations: stations ?? this.stations,
      sourceStation: clearSource ? null : (sourceStation ?? this.sourceStation),
      destinationStation: clearDestination
          ? null
          : (destinationStation ?? this.destinationStation),
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      preference: preference ?? this.preference,
      coachClass: coachClass ?? this.coachClass,
      useBudget: useBudget ?? this.useBudget,
    );
  }
}

class _RouteFinderNotifier extends StateNotifier<_RouteFinderState> {
  _RouteFinderNotifier() : super(_RouteFinderState.initial());

  void setStations(List<String> value) {
    state = state.copyWith(stations: value);
  }

  void setDate(DateTime value) {
    state = state.copyWith(selectedDate: value);
  }

  void setTime(TimeOfDay value) {
    state = state.copyWith(selectedTime: value);
  }

  void swapStations() {
    state = state.copyWith(
      sourceStation: state.destinationStation,
      destinationStation: state.sourceStation,
    );
  }

  void setSource(String value) {
    state = state.copyWith(sourceStation: value);
  }

  void setDestination(String value) {
    state = state.copyWith(destinationStation: value);
  }

  void setCoachClass(String value) {
    state = state.copyWith(coachClass: value);
  }

  void setUseBudget(bool value) {
    state = state.copyWith(useBudget: value);
  }

  void setPreference(String value) {
    state = state.copyWith(preference: value);
  }
}

final _routeFinderProvider =
    StateNotifierProvider.autoDispose<_RouteFinderNotifier, _RouteFinderState>(
      (ref) => _RouteFinderNotifier(),
    );

final _stationPickerFilteredProvider = StateProvider.autoDispose<List<String>>(
  (ref) => [],
);

class RouteFinderPage extends ConsumerStatefulWidget {
  const RouteFinderPage({super.key});

  @override
  ConsumerState<RouteFinderPage> createState() => _RouteFinderPageState();
}

class _RouteFinderPageState extends ConsumerState<RouteFinderPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _budgetCtrl = TextEditingController();
  List<String> get stations => ref.read(_routeFinderProvider).stations;
  String? get sourceStation => ref.read(_routeFinderProvider).sourceStation;
  String? get destinationStation =>
      ref.read(_routeFinderProvider).destinationStation;
  DateTime get selectedDate => ref.read(_routeFinderProvider).selectedDate;
  TimeOfDay get selectedTime => ref.read(_routeFinderProvider).selectedTime;
  String get preference => ref.read(_routeFinderProvider).preference;
  String get coachClass => ref.read(_routeFinderProvider).coachClass;
  bool get useBudget => ref.read(_routeFinderProvider).useBudget;

  static const List<String> _classOptions = [
    'GN',
    '2S',
    'SL',
    '3E',
    'CC',
    '3A',
    '2A',
    '1A',
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadStations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    try {
      final list = await PathApi.getStations();
      ref.read(_routeFinderProvider.notifier).setStations(list);
    } catch (_) {
      try {
        final raw = await rootBundle.loadString(
          'assets/graph_adjacency_list.json',
        );
        final Map<String, dynamic> data = json.decode(raw);
        ref
            .read(_routeFinderProvider.notifier)
            .setStations(data.keys.toList()..sort());
      } catch (_) {}
    }
  }

  String get _timeString {
    final selectedTime = ref.read(_routeFinderProvider).selectedTime;
    final h = selectedTime.hour.toString().padLeft(2, '0');
    final m = selectedTime.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String get _timeAmPm =>
      ref.read(_routeFinderProvider).selectedTime.format(context);

  String get _dateString =>
      "${selectedDate.year.toString().padLeft(4, '0')}"
      "-${selectedDate.month.toString().padLeft(2, '0')}"
      "-${selectedDate.day.toString().padLeft(2, '0')}";

  String get _dateFriendly {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDate = ref.read(_routeFinderProvider).selectedDate;
    return "${d[selectedDate.weekday - 1]}, ${selectedDate.day} ${m[selectedDate.month - 1]} ${selectedDate.year}";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.read(_routeFinderProvider).selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(_routeFinderProvider.notifier).setDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: ref.read(_routeFinderProvider).selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(_routeFinderProvider.notifier).setTime(picked);
    }
  }

  void _swapStations() {
    ref.read(_routeFinderProvider.notifier).swapStations();
  }

  void _openStationPicker({required bool isSource}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StationPickerSheet(
        stations: stations,
        title: isSource ? 'Select Departure Station' : 'Select Arrival Station',
        currentSelection: isSource ? sourceStation : destinationStation,
      ),
    );
    if (selected != null) {
      if (isSource) {
        ref.read(_routeFinderProvider.notifier).setSource(selected);
      } else {
        ref.read(_routeFinderProvider.notifier).setDestination(selected);
      }
    }
  }

  void _findRoute() async {
    if (sourceStation == null || destinationStation == null) {
      _showSnack(
        'Please select both stations',
        Colors.orange[700]!,
        Icons.warning_amber_rounded,
      );
      return;
    }
    if (sourceStation == destinationStation) {
      _showSnack(
        'Source and destination cannot be the same',
        Colors.red[700]!,
        Icons.error_outline,
      );
      return;
    }

    final quote = _loadingQuotes[Random().nextInt(_loadingQuotes.length)];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoadingDialog(quote: quote),
    );

    try {
      int? budget;
      if (useBudget && _budgetCtrl.text.trim().isNotEmpty) {
        budget = int.tryParse(_budgetCtrl.text.trim());
      }
      final response = await PathApi.findRoute(
        source: sourceStation!,
        destination: destinationStation!,
        travelDay: _dateString,
        startTime: _timeString,
        preference: preference,
        coachClass: coachClass,
        budget: budget,
      );

      if (!mounted) return;
      Navigator.pop(context);

      final routeResult = RouteResult.fromJson(response);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              RouteResultScreen(result: routeResult),
          transitionsBuilder: (_, animation, secondaryAnimation, child) =>
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(
        'Could not find route: $e',
        Colors.red[700]!,
        Icons.error_outline,
      );
    }
  }

  void _showSnack(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(_routeFinderProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Route Finder',
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
                    Positioned(right: -50, top: -50, child: _circle(200, 0.05)),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: _circle(150, 0.05),
                    ),
                    const Positioned(
                      bottom: 50,
                      left: 20,
                      child: Text(
                        'India\'s largest railway network\nat your fingertips',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Journey card ──────────────────────────────────────────
                  _card(
                    child: Column(
                      children: [
                        _stationSelector(
                          label: 'FROM',
                          station: sourceStation,
                          hint: 'Select departure station',
                          icon: Icons.trip_origin_rounded,
                          color: AppTheme.accentGreen,
                          onTap: () => _openStationPicker(isSource: true),
                        ),
                        _swapDivider(),
                        _stationSelector(
                          label: 'TO',
                          station: destinationStation,
                          hint: 'Select arrival station',
                          icon: Icons.location_on_rounded,
                          color: AppTheme.accentRed,
                          onTap: () => _openStationPicker(isSource: false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Travel options card ───────────────────────────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Journey Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _optionTile(
                                icon: Icons.calendar_today_rounded,
                                label: 'Travel Date',
                                value: _dateFriendly,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _optionTile(
                                icon: Icons.access_time_rounded,
                                label: 'Depart after',
                                value: _timeAmPm,
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Coach preference row (FIXED) ──────────────────
                        Row(
                          children: [
                            const Icon(
                              Icons.airline_seat_recline_extra_rounded,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Coach:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _prefChip('any', 'Any'),
                                    const SizedBox(width: 6),
                                    _prefChip('ac', 'AC'),
                                    const SizedBox(width: 6),
                                    _prefChip('sleeper', 'Sleeper'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Coach class row ───────────────────────────────
                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_num_rounded,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Class:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _classOptions.map((c) {
                                    final sel = coachClass == c;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                        onTap: () => ref
                                            .read(_routeFinderProvider.notifier)
                                            .setCoachClass(c),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: sel
                                                ? AppTheme.primaryColor
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: sel
                                                  ? AppTheme.primaryColor
                                                  : Colors.grey[300]!,
                                            ),
                                          ),
                                          child: Text(
                                            c,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: sel
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Budget row ────────────────────────────────────
                        Row(
                          children: [
                            const Icon(
                              Icons.savings_outlined,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Set budget:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: useBudget,
                              activeThumbColor: AppTheme.primaryColor,
                              onChanged: (v) => ref
                                  .read(_routeFinderProvider.notifier)
                                  .setUseBudget(v),
                            ),
                            if (useBudget) ...[
                              const SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: _budgetCtrl,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Max Rs e.g. 500',
                                    prefixIcon: const Icon(
                                      Icons.currency_rupee,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Find Route button ─────────────────────────────────────
                  ScaleTransition(
                    scale: _pulseAnim,
                    child: _gradientButton(
                      label: 'Find Best Route',
                      icon: Icons.route_rounded,
                      onTap: _findRoute,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Info chips ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _infoChip(Icons.speed_rounded, 'Fastest Route', [
                          const Color(0xFF42A5F5),
                          const Color(0xFF1E88E5),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoChip(
                          Icons.transfer_within_a_station_rounded,
                          'Min Transfers',
                          [const Color(0xFF66BB6A), const Color(0xFF43A047)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoChip(
                          Icons.airline_seat_flat_rounded,
                          'Coach Info',
                          [const Color(0xFFFF7043), const Color(0xFFE64A19)],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Stats row ─────────────────────────────────────────────
                  _card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem('10,339', 'Stations'),
                        _vDivider(),
                        _statItem('8,420', 'Trains'),
                        _vDivider(),
                        _statItem('210K+', 'Connections'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────────────────────────

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );

  Widget _stationSelector({
    required String label,
    required String? station,
    required String hint,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: station != null
                ? color.withValues(alpha: 0.4)
                : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    station ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: station != null
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _swapDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[200], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: InkWell(
            onTap: _swapStations,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[200], thickness: 1)),
      ],
    ),
  );

  Widget _optionTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prefChip(String value, String label) {
    final selected = preference == value;
    return GestureDetector(
      onTap: () => ref.read(_routeFinderProvider.notifier).setPreference(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, List<Color> colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
    ],
  );

  Widget _vDivider() =>
      Container(height: 36, width: 1, color: Colors.grey[200]);
}

// ── Animated Loading Dialog ────────────────────────────────────────────────────
class _LoadingDialog extends StatefulWidget {
  final String quote;
  const _LoadingDialog({required this.quote});

  @override
  State<_LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.train_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Finding Best Route',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.quote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Station Picker Bottom Sheet ────────────────────────────────────────────────
class StationPickerSheet extends ConsumerStatefulWidget {
  final List<String> stations;
  final String title;
  final String? currentSelection;

  const StationPickerSheet({
    super.key,
    required this.stations,
    required this.title,
    this.currentSelection,
  });

  @override
  ConsumerState<StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends ConsumerState<StationPickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(_stationPickerFilteredProvider.notifier).state = widget.stations;
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    ref.read(_stationPickerFilteredProvider.notifier).state = q.isEmpty
        ? widget.stations
        : widget.stations.where((s) => s.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = ref.watch(_stationPickerFilteredProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[500]),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search station...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No stations found',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      final isSelected = s == widget.currentSelection;
                      return InkWell(
                        onTap: () => Navigator.pop(context, s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.07)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[100]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.train_rounded,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[350],
                                size: 20,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
