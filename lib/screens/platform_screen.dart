import 'package:flutter/material.dart';
import '../data/platform1_data.dart';
import '../models/station.dart';
import 'panorama_screen.dart';

class PlatformScreen extends StatelessWidget {
  const PlatformScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
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
              )
            : null,
        title: const Text(
          'Station 3D Mapping',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B2A), Color(0xFF080C14)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF00C6FF,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF00C6FF,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.domain,
                          color: Color(0xFF00C6FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'KERALA RAILWAYS',
                        style: TextStyle(
                          color: Color(0xFF00C6FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Station\n3D Mapping',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore railway stations in immersive 360° panorama',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.location_city,
                        label: '${allStations.length} Station',
                        color: const Color(0xFF00C6FF),
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.panorama,
                        label: '${platform1Scenes.length} Scenes',
                        color: const Color(0xFF7B61FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'SELECT STATION',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _StationCard(
                  station: allStations[index],
                  onTap: () => _onStationTapped(context, allStations[index]),
                ),
                childCount: allStations.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }



  void _onStationTapped(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _WhereAreYouSheet(
        station: station,
        onStartingPointSelected: (startingPoint, isFreeView) {
          Navigator.pop(ctx);
          if (isFreeView) {
            // Free view: go straight to panorama with no guidance
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PanoramaScreen(
                  scenes: startingPoint.scenes,
                  initialIndex: 0,
                  highlightIconId: null,
                ),
              ),
            );
          } else {
            // Show destination picker
            _showDestinationPicker(context, station, startingPoint);
          }
        },
      ),
    );
  }



  void _showDestinationPicker(
    BuildContext context,
    Station station,
    StartingPoint startingPoint,
  ) {
    // Only show destinations that exist in this starting point's scene map
    final available = station.destinations
        .where((d) => startingPoint.destinationSceneMap.containsKey(d.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _WhereToGoSheet(
        startingPoint: startingPoint,
        destinations: available,
        onDestinationSelected: (destination) {
          Navigator.pop(ctx);
          final sceneIndex =
              startingPoint.destinationSceneMap[destination.id] ?? 0;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PanoramaScreen(
                scenes: startingPoint.scenes,
                initialIndex: sceneIndex,
                highlightIconId: destination.id,
              ),
            ),
          );
        },
      ),
    );
  }
}



class _WhereAreYouSheet extends StatelessWidget {
  final Station station;
  final void Function(StartingPoint sp, bool isFreeView)
  onStartingPointSelected;

  const _WhereAreYouSheet({
    required this.station,
    required this.onStartingPointSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Where are you now?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your current location in the station',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          // Starting point options (excluding the special free_view id)
          ...station.startingPoints.where((sp) => sp.id != 'free_view').map(
            (sp) => _LocationTile(
              icon: sp.icon,
              label: sp.label,
              description: sp.description,
              color: station.accentColor,
              onTap: () => onStartingPointSelected(sp, false),
            ),
          ),
          // Free View option (specifically finding the free_view id)
          _LocationTile(
            icon: Icons.explore,
            label: 'Free View',
            description: 'Explore without guidance',
            color: Colors.white38,
            onTap: () {
              final fv = station.startingPoints.firstWhere(
                (sp) => sp.id == 'free_view',
                orElse: () => station.startingPoints.first,
              );
              onStartingPointSelected(fv, true);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _LocationTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}



class _WhereToGoSheet extends StatelessWidget {
  final StartingPoint startingPoint;
  final List<Destination> destinations;
  final void Function(Destination d) onDestinationSelected;

  const _WhereToGoSheet({
    required this.startingPoint,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Where do you want to go?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'From ${startingPoint.label} — tap a destination',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              physics: const NeverScrollableScrollPhysics(),
              children: destinations
                  .map(
                    (d) => _DestinationChip(
                      destination: d,
                      onTap: () => onDestinationSelected(d),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _DestinationChip({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: destination.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: destination.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(destination.icon, color: destination.color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                destination.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const _StationCard({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: station.accentColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1923), Color(0xFF0A1018)],
          ),
          boxShadow: [
            BoxShadow(
              color: station.accentColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: station.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: station.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      station.code,
                      style: TextStyle(
                        color: station.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: station.accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: station.accentColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                station.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                station.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.panorama_outlined,
                    color: station.accentColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${platform1Scenes.length} panorama scenes',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Explore →',
                    style: TextStyle(
                      color: station.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
