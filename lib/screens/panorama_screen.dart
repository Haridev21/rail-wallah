import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

import '../models/panorama_icon.dart' as model;
import '../models/panorama_scene.dart';

class _PanoramaUiState {
  const _PanoramaUiState({
    this.currentIndex = 0,
    this.debugLat = 0,
    this.debugLng = 0,
  });

  final int currentIndex;
  final double debugLat;
  final double debugLng;

  _PanoramaUiState copyWith({
    int? currentIndex,
    double? debugLat,
    double? debugLng,
  }) {
    return _PanoramaUiState(
      currentIndex: currentIndex ?? this.currentIndex,
      debugLat: debugLat ?? this.debugLat,
      debugLng: debugLng ?? this.debugLng,
    );
  }
}

class _PanoramaUiNotifier extends StateNotifier<_PanoramaUiState> {
  _PanoramaUiNotifier() : super(const _PanoramaUiState());

  void initialize(int initialIndex) {
    state = state.copyWith(currentIndex: initialIndex);
  }

  void goNext(int maxLength) {
    if (state.currentIndex < maxLength - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void goPrev() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void setDebug(double lat, double lng) {
    state = state.copyWith(debugLat: lat, debugLng: lng);
  }
}

final _panoramaUiProvider =
    StateNotifierProvider.autoDispose<_PanoramaUiNotifier, _PanoramaUiState>(
      (ref) => _PanoramaUiNotifier(),
    );

class PanoramaScreen extends ConsumerStatefulWidget {
  final List<PanoramaScene> scenes;
  final int initialIndex;
  final String? highlightIconId;

  const PanoramaScreen({
    super.key,
    required this.scenes,
    required this.initialIndex,
    required this.highlightIconId,
  });

  @override
  ConsumerState<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends ConsumerState<PanoramaScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    ref.read(_panoramaUiProvider.notifier).initialize(widget.initialIndex);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  PanoramaScene get _currentScene =>
      widget.scenes[ref.watch(_panoramaUiProvider).currentIndex];
  bool get _hasNext =>
      ref.watch(_panoramaUiProvider).currentIndex < widget.scenes.length - 1;
  bool get _hasPrev => ref.watch(_panoramaUiProvider).currentIndex > 0;
  bool get _isGuided => widget.highlightIconId != null;

  void _goNext() {
    ref.read(_panoramaUiProvider.notifier).goNext(widget.scenes.length);
  }

  void _goPrev() {
    ref.read(_panoramaUiProvider.notifier).goPrev();
  }

  void _showIconInfo(model.PanoramaIcon icon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: icon.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: icon.color, width: 2),
              ),
              child: Icon(icon.icon, color: icon.color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              icon.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Text(
                'Lng: ${icon.longitude.toStringAsFixed(2)} | Lat: ${icon.latitude.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: icon.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Hotspot> _buildHotspots() {
    return _currentScene.icons.map((icon) {
      final isDestination = icon.id == widget.highlightIconId;
      return Hotspot(
        longitude: icon.longitude,
        latitude: icon.latitude,
        width: isDestination ? 80 : 60,
        height: isDestination ? 80 : 60,
        widget: GestureDetector(
          onTap: () => _showIconInfo(icon),
          child: isDestination
              ? _GlowingDestinationIcon(
                  icon: icon,
                  glowAnimation: _glowAnimation,
                )
              : _NormalIcon(icon: icon),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(_panoramaUiProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentScene.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${vm.currentIndex + 1} / ${widget.scenes.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (kDebugMode)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'DEBUG',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          KeyedSubtree(
            key: ValueKey(vm.currentIndex),
            child: PanoramaViewer(
              hotspots: _buildHotspots(),
              onTap: (longitude, latitude, tilt) {
                if (kDebugMode) {
                  ref
                      .read(_panoramaUiProvider.notifier)
                      .setDebug(latitude, longitude);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange[800],
                      duration: const Duration(seconds: 3),
                      content: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lat: ${latitude.toStringAsFixed(2)} | Lng: ${longitude.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              child: Image.asset(
                _currentScene.assetPath,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 64,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Panorama image not found',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Guided navigation banner
          if (_isGuided)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00C6FF).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.navigation,
                      color: Color(0xFF00C6FF),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Navigating to: ${_currentScene.icons.firstWhere((i) => i.id == widget.highlightIconId, orElse: () => _currentScene.icons.first).label}  •  Look for the glowing icon',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Prev arrow
          if (_hasPrev)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goPrev,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

          // Next arrow
          if (_hasNext)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goNext,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

          // Dot indicators
          Positioned(
            bottom: kDebugMode ? 60 : 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.scenes.length, (i) {
                final isActive = i == vm.currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blueAccent : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Debug overlay
          if (kDebugMode)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '🛠 Tap anywhere → Lat/Lng | Last: ${vm.debugLat.toStringAsFixed(2)}, ${vm.debugLng.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NormalIcon extends StatelessWidget {
  final model.PanoramaIcon icon;
  const _NormalIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border: Border.all(color: icon.color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: icon.color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon.icon, color: icon.color, size: 22),
          const SizedBox(height: 2),
          Text(
            icon.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _GlowingDestinationIcon extends StatelessWidget {
  final model.PanoramaIcon icon;
  final Animation<double> glowAnimation;

  const _GlowingDestinationIcon({
    required this.icon,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnimation,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: icon.color.withValues(alpha: glowAnimation.value * 0.8),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: icon.color.withValues(
                    alpha: glowAnimation.value * 0.6,
                  ),
                  blurRadius: 20 * glowAnimation.value,
                  spreadRadius: 6 * glowAnimation.value,
                ),
              ],
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              shape: BoxShape.circle,
              border: Border.all(color: icon.color, width: 2.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon.icon, color: icon.color, size: 24),
                const SizedBox(height: 2),
                Text(
                  icon.label,
                  style: TextStyle(
                    color: icon.color,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: icon.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'DESTINATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 6,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
