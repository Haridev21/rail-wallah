import 'package:flutter/material.dart';
import '../models/panorama_icon.dart';
import '../models/panorama_scene.dart';
import '../models/station.dart';

final List<PanoramaScene> freeView = [
  PanoramaScene(
    label: 'Scene 1',
    assetPath: 'assets/platform1/1.jpg',
    icons: [
      PanoramaIcon(
        id: 'ticket_1',
        label: 'Ticket Counter',
        icon: Icons.confirmation_number,
        color: Colors.orange,
        longitude: -12.10,
        latitude: 0.0,
      ),
    ],
  ),
  PanoramaScene(
    label: 'Scene 2',
    assetPath: 'assets/platform1/2.jpg',
    icons: [
      PanoramaIcon(
        id: 'ticket_1',
        label: 'Ticket Counter',
        icon: Icons.confirmation_number,
        color: Colors.orange,
        longitude: -45.0,
        latitude: 0.0,
      ),
    ],
  ),
  PanoramaScene(
    label: 'Scene 3',
    assetPath: 'assets/platform1/3.jpg',
    icons: [
      PanoramaIcon(
        id: 'washroom_1',
        label: 'Washroom',
        icon: Icons.wc,
        color: Colors.blue,
        longitude: 185.0,
        latitude: 20.0,
      ),
      PanoramaIcon(
        id: 'dustbin_1',
        label: 'Dustbin',
        icon: Icons.delete_outline,
        color: Colors.green,
        longitude: 30.0,
        latitude: 0.0,
      ),
      PanoramaIcon(
        id: 'waiting_1',
        label: 'Waiting Area',
        icon: Icons.chair,
        color: Colors.purple,
        longitude: 15.0,
        latitude: 0.0,
      ),
    ],
  ),
  PanoramaScene(
    label: 'Scene 4',
    assetPath: 'assets/platform1/platform1.jpg',
    icons: [
      PanoramaIcon(
        id: 'washroom_1',
        label: 'Washroom',
        icon: Icons.wc,
        color: Colors.blue,
        longitude: 55.0,
        latitude: 10.0,
      ),
      PanoramaIcon(
        id: 'ticket_1',
        label: 'Ticket Counter',
        icon: Icons.confirmation_number,
        color: Colors.orange,
        longitude: 110.0,
        latitude: 10.0,
      ),
      PanoramaIcon(
        id: 'dustbin_1',
        label: 'Dustbin',
        icon: Icons.delete_outline,
        color: Colors.green,
        longitude: 180.0,
        latitude: 0.0,
      ),
      PanoramaIcon(
        id: 'waiting_1',
        label: 'Waiting Area',
        icon: Icons.chair,
        color: Colors.purple,
        longitude: 165.0,
        latitude: 0.0,
      ),
    ],
  ),
];

final List<PanoramaScene> platform1Scenes = [
  PanoramaScene(
    label: 'Scene 4',
    assetPath: 'assets/platform1/platform1.jpg',
    icons: [
      PanoramaIcon(
        id: 'washroom_1',
        label: 'Washroom',
        icon: Icons.wc,
        color: Colors.blue,
        longitude: 55.0,
        latitude: 10.0,
      ),
      PanoramaIcon(
        id: 'ticket_1',
        label: 'Ticket Counter',
        icon: Icons.confirmation_number,
        color: Colors.orange,
        longitude: 110.0,
        latitude: 10.0,
      ),
      PanoramaIcon(
        id: 'dustbin_1',
        label: 'Dustbin',
        icon: Icons.delete_outline,
        color: Colors.green,
        longitude: 180.0,
        latitude: 0.0,
      ),
      PanoramaIcon(
        id: 'waiting_1',
        label: 'Waiting Area',
        icon: Icons.chair,
        color: Colors.purple,
        longitude: 165.0,
        latitude: 0.0,
      ),
    ],
  ),
];

final List<PanoramaScene> entranceScenes = [
  PanoramaScene(
    label: 'Scene 1',
    assetPath: 'assets/platform1/1.jpg',
    icons: [
      PanoramaIcon(
        id: 'ticket_1',
        label: 'Ticket Counter',
        icon: Icons.confirmation_number,
        color: Colors.orange,
        longitude: -12.10,
        latitude: 0.0,
      ),
    ],
  ),
  PanoramaScene(
    label: 'Scene 2',
    assetPath: 'assets/platform1/2.jpg',
    icons: [
      PanoramaIcon(
        id: 'ticket_1',
        label: 'Ticket Counter',
        icon: Icons.confirmation_number,
        color: Colors.orange,
        longitude: -45.0,
        latitude: 0.0,
      ),
    ],
  ),
  PanoramaScene(
    label: 'Scene 3',
    assetPath: 'assets/platform1/3.jpg',
    icons: [
      PanoramaIcon(
        id: 'washroom_1',
        label: 'Washroom',
        icon: Icons.wc,
        color: Colors.blue,
        longitude: 185.0,
        latitude: 20.0,
      ),
      PanoramaIcon(
        id: 'dustbin_1',
        label: 'Dustbin',
        icon: Icons.delete_outline,
        color: Colors.green,
        longitude: 30.0,
        latitude: 0.0,
      ),
      PanoramaIcon(
        id: 'waiting_1',
        label: 'Waiting Area',
        icon: Icons.chair,
        color: Colors.purple,
        longitude: 15.0,
        latitude: 0.0,
      ),
    ],
  ),
];

const List<Destination> allDestinations = [
  Destination(
    id: 'washroom_1',
    label: 'Washroom',
    icon: Icons.wc,
    color: Colors.blue,
  ),
  Destination(
    id: 'ticket_1',
    label: 'Ticket Counter',
    icon: Icons.confirmation_number,
    color: Colors.orange,
  ),
  Destination(
    id: 'waiting_1',
    label: 'Waiting Area',
    icon: Icons.chair,
    color: Colors.purple,
  ),
  Destination(
    id: 'dustbin_1',
    label: 'Dustbin',
    icon: Icons.delete_outline,
    color: Colors.green,
  ),
  // Destination(id: 'bridge_1', label: 'Platform 2 Bridge', icon: Icons.stairs, color: Colors.red),
];

final Station ettumanoorStation = Station(
  name: 'Ettumanoor Railway Station',
  subtitle: 'Kottayam District · Kerala',
  code: 'ETM',
  accentColor: const Color(0xFF00C6FF),
  destinations: allDestinations,
  startingPoints: [
    StartingPoint(
      id: 'platform1',
      label: 'Platform 1',
      description: 'Starting from Platform 1',
      icon: Icons.train,
      scenes: platform1Scenes,
      destinationSceneMap: {
        'washroom_1': 0,
        'ticket_1': 0,
        'dustbin_1': 0,
        'waiting_1': 0,
      },
    ),
    StartingPoint(
      id: 'free_view',
      label: 'Free View',
      description: 'Explore the whole station',
      icon: Icons.explore,
      scenes: freeView,
      destinationSceneMap: {},
    ),

    StartingPoint(
      id: 'entrance',
      label: 'Entrance',
      description: 'Starting from Station Entrance',
      icon: Icons.door_front_door,
      scenes: entranceScenes,
      destinationSceneMap: {
        'ticket_1': 0,
        'washroom_1': 2,
        'dustbin_1': 2,
        'waiting_1': 2,
      },
    ),
  ],
);

final List<Station> allStations = [ettumanoorStation];
