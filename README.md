# Rail-Wallah – Railway Passenger Support System

Rail-Wallah is a Railway Passenger Support System developed to provide railway passengers with multiple railway services in a single mobile application. The application helps users access train schedules, find the best train routes, check ticket status, register complaints, and navigate railway stations.

## Features

- View Train Schedule
- Intelligent Train Route Finder
- Complaint Registration and Tracking
- Ticket Status (PNR Status Check)
- 3D Station Navigation
- Emergency SOS Assistance
- Real-time Passenger Support Services

## Problem Statement

Passengers currently depend on multiple applications to access railway services such as train schedules, ticket status, complaint management, and navigation. Rail-Wallah solves this problem by integrating these services into one platform.

## Modules

### 1. Train Schedule Module
Allows passengers to:
- Search train schedules
- View train timings
- Check arrival and departure details
- View platform information

### 2. Train Route Finder
- Suggests the best route between stations
- Uses Modified Dijkstra’s Algorithm
- Finds alternative connecting routes when direct trains are unavailable

### 3. Complaint Management System
- Register railway complaints
- Generate complaint ID
- Track complaint status

### 4. Ticket Status Module
- Check PNR status
- Redirect to ConfirmTkt for detailed ticket information

### 5. 3D Station Navigation
- Helps passengers navigate railway stations
- Provides station maps and important facility locations

## Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- Python
- Flask

### Database
- Firebase Firestore

### APIs
- Rapid API (Train Schedule Information)
- ConfirmTkt Integration (PNR Status)

### Tools Used
- Visual Studio Code
- Postman
- Git & GitHub

## System Architecture

The project follows a three-tier architecture:

```text
Flutter Mobile App
        ↓
Flask REST API Backend
        ↓
Firebase Database
```

## Algorithm Used

### Modified Dijkstra’s Algorithm

The route finder module uses a modified version of Dijkstra’s Algorithm to:

- Find shortest railway paths
- Handle train changes
- Consider waiting time
- Minimize travel duration

## Installation

### Prerequisites

Make sure you have installed:

- Flutter SDK
- Python 3.x
- Firebase
- Git

### Clone Repository

```bash
git clone https://github.com/Haridev21/rail-wallah.git
cd rail-wallah
```

### Frontend Setup

```bash
flutter pub get
flutter run
```

### Backend Setup

Install dependencies:

```bash
pip install flask flask-cors firebase-admin requests
```

Run backend:

```bash
python app.py
```

## Screenshots

### Home Screen
Displays all railway passenger services.

### Route Finder
Finds optimal train routes.

### Complaint Module
Register and track railway complaints.

### Train Schedule
Displays train timeline and station information.

### PNR Status
Check ticket status using PNR number.

### 3D Station Navigation
Navigate railway stations using panoramic views.

## Functional Requirements

- View train schedules
- Find railway routes
- Register complaints
- Check ticket status
- Station navigation
- Emergency assistance

## Non-Functional Requirements

- Fast response time
- Reliable system
- Secure passenger data
- User-friendly interface
- Scalable architecture

## Testing

The system was tested using:

- Unit Testing
- Integration Testing
- System Testing
- User Acceptance Testing (UAT)

All major modules passed testing successfully.

## Future Enhancements

- AI-based route recommendations
- Real-time train tracking
- Voice assistant support
- Offline station maps
- Multi-language support

## Team Members

- Haridev M (LKTE23CS077)
- Silpa P S (LKTE23CS078)
- Sanjay Nair (KTE23CS057)
- Anandakrishnan V S (LKTE23CS075)

## Institution

Department of Computer Science and Engineering  
Rajiv Gandhi Institute of Technology (Government Engineering College)  
Kottayam, Kerala

## License

This project is developed for academic purposes under APJ Abdul Kalam Technological University (KTU).
