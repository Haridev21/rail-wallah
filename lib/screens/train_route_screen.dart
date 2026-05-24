import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../api/train_api.dart';

// Theme colors matching home screen
class AppTheme {
  static const primaryColor = Color(0xFF1A237E);
  static const primaryLight = Color(0xFF283593);
  static const backgroundColor = Color(0xFFF8F9FA);
}

class _TrainTimelineState {
  const _TrainTimelineState({
    this.stations = const [],
    this.lastMessage,
    this.loading = false,
    this.isError = false,
    this.trainName,
  });

  final List<TrainStation> stations;
  final String? lastMessage;
  final bool loading;
  final bool isError;
  final String? trainName;

  _TrainTimelineState copyWith({
    List<TrainStation>? stations,
    String? lastMessage,
    bool clearLastMessage = false,
    bool? loading,
    bool? isError,
    String? trainName,
    bool clearTrainName = false,
  }) {
    return _TrainTimelineState(
      stations: stations ?? this.stations,
      lastMessage: clearLastMessage ? null : (lastMessage ?? this.lastMessage),
      loading: loading ?? this.loading,
      isError: isError ?? this.isError,
      trainName: clearTrainName ? null : (trainName ?? this.trainName),
    );
  }
}

class _TrainTimelineNotifier extends StateNotifier<_TrainTimelineState> {
  _TrainTimelineNotifier() : super(const _TrainTimelineState());

  Future<void> fetchTrain(String trainNo) async {
    state = state.copyWith(
      loading: true,
      stations: const [],
      clearLastMessage: true,
      isError: false,
      clearTrainName: true,
    );
    final response = await TrainAPI.fetchTrainRoute(trainNo);
    state = state.copyWith(
      stations: response.stations,
      lastMessage: response.message,
      isError: response.isError,
      trainName: response.trainName,
      loading: false,
    );
  }
}

final _trainTimelineProvider =
    StateNotifierProvider.autoDispose<
      _TrainTimelineNotifier,
      _TrainTimelineState
    >((ref) => _TrainTimelineNotifier());

class TrainTimelinePage extends ConsumerStatefulWidget {
  const TrainTimelinePage({super.key});

  @override
  ConsumerState<TrainTimelinePage> createState() => _TrainTimelinePageState();
}

class _TrainTimelinePageState extends ConsumerState<TrainTimelinePage> {
  final TextEditingController _controller = TextEditingController();

  String convertTo12Hour(String timing) {
    try {
      final timePart = timing.substring(0, 5);
      final dateTime = DateFormat("HH:mm").parse(timePart);
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      return timing;
    }
  }

  Color getStatusColor(String delay) {
    if (delay.contains("hr") ||
        delay.contains("min") &&
            int.parse(RegExp(r'\d+').firstMatch(delay)?.group(0) ?? "0") > 15) {
      return const Color(0xFFD32F2F);
    } else if (delay.contains("min") &&
        int.parse(RegExp(r'\d+').firstMatch(delay)?.group(0) ?? "0") > 5) {
      return const Color(0xFFF57C00);
    } else {
      return const Color(0xFF388E3C);
    }
  }

  String getStatusText(String delay) {
    if (delay.contains("hr") ||
        delay.contains("min") &&
            int.parse(RegExp(r'\d+').firstMatch(delay)?.group(0) ?? "0") > 15) {
      return "Mostly Delayed";
    } else if (delay.contains("min") &&
        int.parse(RegExp(r'\d+').firstMatch(delay)?.group(0) ?? "0") > 5) {
      return "Irregular Ontime";
    } else {
      return "Mostly Ontime";
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(_trainTimelineProvider);
    final stations = vm.stations;
    final lastMessage = vm.lastMessage;
    final loading = vm.loading;
    final isError = vm.isError;
    final trainName = vm.trainName;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Pop all routes and go back to home screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: const Text(
          'Train Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header section with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primaryColor, AppTheme.primaryLight],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  // Search input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Enter Train Number",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(
                          Icons.train_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              if (_controller.text.isNotEmpty) {
                                ref
                                    .read(_trainTimelineProvider.notifier)
                                    .fetchTrain(_controller.text);
                              }
                            },
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Train name and route info card
                  if ((trainName ?? '').isNotEmpty && stations.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.train_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  trainName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    stations.first.stationName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    stations.last.stationName,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Banner showing last reached station message
                  if ((lastMessage ?? '').isNotEmpty && !isError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                            AppTheme.primaryLight.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lastMessage ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Loading or timeline
                  loading
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Loading train route...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : stations.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isError
                                        ? const Color(0xFFFFEBEE)
                                        : Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isError
                                        ? Icons.error_outline_rounded
                                        : Icons.search_off_rounded,
                                    size: 64,
                                    color: isError
                                        ? const Color(0xFFD32F2F)
                                        : Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isError
                                      ? (lastMessage ??
                                            'Invalid train number. Please check and try again.')
                                      : 'Enter a train number to view route',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isError
                                        ? const Color(0xFFD32F2F)
                                        : Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: isError
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isError) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Please verify the train number and try again.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: stations.length,
                              itemBuilder: (context, index) {
                                final station = stations[index];
                                final color = getStatusColor(station.delay);
                                final statusText = getStatusText(station.delay);
                                final time = convertTo12Hour(station.timing);

                                return TimelineItem(
                                  status: statusText,
                                  color: color,
                                  station: station.stationName,
                                  time: time,
                                  platform: station.platform,
                                  isCurrentStation: station.isCurrentStation,
                                  isFirst: index == 0,
                                  isLast: index == stations.length - 1,
                                );
                              },
                            ),
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
}

class TimelineItem extends StatefulWidget {
  final String status;
  final Color color;
  final String station;
  final String time;
  final String? platform;
  final bool isCurrentStation;
  final bool isFirst;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.status,
    required this.color,
    required this.station,
    required this.time,
    this.platform,
    this.isCurrentStation = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<TimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isCurrentStation) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status badge
          SizedBox(
            width: 115,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.status,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Timeline line and dot
          SizedBox(
            width: 24,
            child: Stack(
              children: [
                // Vertical line
                if (!widget.isFirst)
                  Positioned(
                    left: 10,
                    top: 0,
                    height: 20,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey[300]!,
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 10,
                  top: 20,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.3),
                          widget.isLast
                              ? Colors.grey[300]!
                              : AppTheme.primaryColor.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),

                // Circle/Dot with pulsing glow for current station
                widget.isCurrentStation
                    ? Positioned(
                        left: 0,
                        top: 10,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final value = _pulseAnimation.value;
                            return Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.3 + (value * 0.4)),
                                    blurRadius: 8 + (value * 12),
                                    spreadRadius: 2 + (value * 6),
                                  ),
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.15 + (value * 0.2)),
                                    blurRadius: 16 + (value * 8),
                                    spreadRadius: 4 + (value * 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF66BB6A),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Positioned(
                        left: 3,
                        top: 13,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: widget.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Station info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.station,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: widget.isCurrentStation ? 16 : 15,
                                color: widget.isCurrentStation
                                    ? AppTheme.primaryColor
                                    : Colors.black87,
                              ),
                            ),
                            if (widget.isCurrentStation)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4CAF50),
                                        Color(0xFF66BB6A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '● CURRENT STATION',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isCurrentStation
                              ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.time,
                          style: TextStyle(
                            color: widget.isCurrentStation
                                ? const Color(0xFF4CAF50)
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.platform != null &&
                      widget.platform!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Platform ${widget.platform}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
