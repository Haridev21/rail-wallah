import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'train_route_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E), // Deep indigo
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Alert Card
              _buildEmergencyAlertCard(),
              const SizedBox(height: 20),

              // Register Complaint - NEW FEATURE
              _buildComplaintCard(context),
              const SizedBox(height: 16),

              // Track Complaint - NEW FEATURE
              _buildTrackComplaintCard(context),
              const SizedBox(height: 16),

              // Report an Issue
              _buildExpandableCard(
                title: 'Report Safety Issue',
                subtitle:
                    'Report incidents like stone throwing, harassment, etc.',
                icon: Icons.keyboard_arrow_down,
              ),
              const SizedBox(height: 16),

              // Nearest Help
              _buildExpandableCard(
                title: 'Nearest Help',
                subtitle:
                    'Find nearest hospital, police & railway station etc.',
                icon: Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildEmergencyAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53935), // Red for emergency
            Color(0xFFD32F2F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Need Emergency Assistance?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'For immediate emergency services, call the national emergency number 999. You can also contact Bangladesh Railway helpline at 131 for railway-related assistance.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Register Complaint Card
  Widget _buildComplaintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0277BD), Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterComplaintScreen(),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.report_problem_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register Complaint',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lost & found, cleanliness, staff behavior, etc.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // NEW: Track Complaint Card
  Widget _buildTrackComplaintCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00838F), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00838F).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TrackComplaintScreen(),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.track_changes_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Track Complaint',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Check status of your registered complaints',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.grey[700], size: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext navContext) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A237E), // Deep indigo
        unselectedItemColor: Colors.grey,
        currentIndex: 3,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                navContext,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                navContext,
                MaterialPageRoute(
                  builder: (context) => const TrainTimelinePage(),
                ),
              );
              break;
            case 2:
              ScaffoldMessenger.of(navContext).showSnackBar(
                const SnackBar(content: Text('Bookings coming soon!')),
              );
              break;
            case 3:
              // Already on Emergency screen
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_rounded),
            label: 'Train Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency_rounded),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

// NEW: Register Complaint Screen - Following Sequence Diagram
final _registerSelectedCategoryProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);
final _registerIsSubmittingProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

final _trackSearchModeProvider = StateProvider.autoDispose<int>((ref) => 0);
final _trackIsLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _trackComplaintDetailsProvider =
    StateProvider.autoDispose<Map<String, dynamic>?>((ref) => null);
final _trackPhoneComplaintsProvider =
    StateProvider.autoDispose<List<Map<String, dynamic>>>((ref) => []);

class RegisterComplaintScreen extends ConsumerStatefulWidget {
  const RegisterComplaintScreen({super.key});

  @override
  ConsumerState<RegisterComplaintScreen> createState() =>
      _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState
    extends ConsumerState<RegisterComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _trainNumberController = TextEditingController();
  final _coachNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final List<String> _categories = [
    'Lost & Found',
    'Cleanliness',
    'Staff Behavior',
    'Safety Issue',
    'Medical Emergency',
    'Food Quality',
    'Electrical Issue',
    'Water Supply',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _trainNumberController.dispose();
    _coachNumberController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // Following sequence diagram flow
  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(_registerIsSubmittingProvider.notifier).state = true;

    try {
      // Following sequence diagram flow:
      // 1. Submit complaint data to Backend API (Firestore in this case)
      final docRef = await FirebaseFirestore.instance
          .collection('complaints')
          .add({
            'category': ref.read(_registerSelectedCategoryProvider),
            'trainNumber': _trainNumberController.text,
            'coachNumber': _coachNumberController.text,
            'description': _descriptionController.text,
            'phoneNumber': _phoneNumberController.text.trim(),
            'status': 'Registered',
            'submittedDate': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      // 2. Local representation of the generated ID
      final complaintId = docRef.id;

      ref.read(_registerIsSubmittingProvider.notifier).state = false;

      if (mounted) {
        // Show success message with complaint details
        _showSuccessDialog(complaintId);
      }
    } catch (e) {
      ref.read(_registerIsSubmittingProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String complaintId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Complaint Registered Successfully',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Complaint ID',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    complaintId,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Status: ', style: TextStyle(fontSize: 12)),
                  Text(
                    'Registered',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Track your complaint using this ID or your phone number',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to Emergency screen
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackComplaintScreen(),
                ),
              );
            },
            child: const Text('Track Complaint'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(_registerSelectedCategoryProvider);
    final isSubmitting = ref.watch(_registerIsSubmittingProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E), // Deep indigo
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register Complaint',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF283593)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill in the details below to register your complaint. You will receive a unique complaint ID.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Complaint Category
                const Text(
                  'Complaint Category *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Select category',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(_registerSelectedCategoryProvider.notifier).state =
                        value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Train Number
                const Text(
                  'Train Number *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _trainNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter train number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter train number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Coach Number
                const Text(
                  'Coach Number (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _coachNumberController,
                  decoration: InputDecoration(
                    hintText: 'Enter coach number (e.g., B3)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone Number
                const Text(
                  'Phone Number *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number (e.g., 01XXXXXXXXX)',
                    prefixIcon: const Icon(
                      Icons.phone_rounded,
                      color: Color(0xFF0277BD),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 10) {
                      return 'Please enter a valid phone number (min 10 digits)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Describe your complaint in detail...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your complaint';
                    }
                    if (value.length < 10) {
                      return 'Please provide more details (minimum 10 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitComplaint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0277BD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Submit Complaint',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

// NEW: Track Complaint Screen - Following Sequence Diagram
class TrackComplaintScreen extends ConsumerStatefulWidget {
  const TrackComplaintScreen({super.key});

  @override
  ConsumerState<TrackComplaintScreen> createState() =>
      _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends ConsumerState<TrackComplaintScreen> {
  final _complaintIdController = TextEditingController();
  final _phoneSearchController = TextEditingController();

  @override
  void dispose() {
    _complaintIdController.dispose();
    _phoneSearchController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
    }
    return timestamp.toString();
  }

  // Track by Complaint ID
  Future<void> _trackById() async {
    final id = _complaintIdController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Complaint ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(_trackIsLoadingProvider.notifier).state = true;
    ref.read(_trackComplaintDetailsProvider.notifier).state = null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        ref.read(_trackComplaintDetailsProvider.notifier).state = {
          'id': doc.id,
          'category': data['category'] ?? 'N/A',
          'status': data['status'] ?? 'Registered',
          'trainNumber': data['trainNumber'] ?? 'N/A',
          'coachNumber': data['coachNumber'] ?? 'N/A',
          'phoneNumber': data['phoneNumber'] ?? 'N/A',
          'description': data['description'] ?? 'N/A',
          'submittedDate': _formatDate(data['submittedDate']),
          'lastUpdated': _formatDate(data['lastUpdated']),
        };
        ref.read(_trackIsLoadingProvider.notifier).state = false;
      } else {
        ref.read(_trackIsLoadingProvider.notifier).state = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint ID not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ref.read(_trackIsLoadingProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Track by Phone Number
  Future<void> _trackByPhone() async {
    final phone = _phoneSearchController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(_trackIsLoadingProvider.notifier).state = true;
    ref.read(_trackPhoneComplaintsProvider.notifier).state = [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .where('phoneNumber', isEqualTo: phone)
          .orderBy('submittedDate', descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final results = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'category': data['category'] ?? 'N/A',
            'status': data['status'] ?? 'Registered',
            'trainNumber': data['trainNumber'] ?? 'N/A',
            'coachNumber': data['coachNumber'] ?? 'N/A',
            'phoneNumber': data['phoneNumber'] ?? 'N/A',
            'description': data['description'] ?? 'N/A',
            'submittedDate': _formatDate(data['submittedDate']),
            'lastUpdated': _formatDate(data['lastUpdated']),
          };
        }).toList();

        ref.read(_trackPhoneComplaintsProvider.notifier).state = results;
        ref.read(_trackIsLoadingProvider.notifier).state = false;
      } else {
        ref.read(_trackIsLoadingProvider.notifier).state = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No complaints found for this phone number'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      ref.read(_trackIsLoadingProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return const Color(0xFF2196F3);
      case 'in progress':
        return const Color(0xFFFF9800);
      case 'resolved':
        return const Color(0xFF4CAF50);
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchMode = ref.watch(_trackSearchModeProvider);
    final isLoading = ref.watch(_trackIsLoadingProvider);
    final complaintDetails = ref.watch(_trackComplaintDetailsProvider);
    final phoneComplaints = ref.watch(_trackPhoneComplaintsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E), // Deep indigo
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Complaint',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00838F), Color(0xFF006064)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00838F).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Track by Complaint ID or by your registered phone number.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Toggle Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildToggleTab(
                      label: 'Complaint ID',
                      icon: Icons.confirmation_number_rounded,
                      isSelected: searchMode == 0,
                      onTap: () {
                        ref.read(_trackSearchModeProvider.notifier).state = 0;
                        ref
                                .read(_trackComplaintDetailsProvider.notifier)
                                .state =
                            null;
                        ref.read(_trackPhoneComplaintsProvider.notifier).state =
                            [];
                      },
                    ),
                    _buildToggleTab(
                      label: 'Phone Number',
                      icon: Icons.phone_rounded,
                      isSelected: searchMode == 1,
                      onTap: () {
                        ref.read(_trackSearchModeProvider.notifier).state = 1;
                        ref
                                .read(_trackComplaintDetailsProvider.notifier)
                                .state =
                            null;
                        ref.read(_trackPhoneComplaintsProvider.notifier).state =
                            [];
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Search by Complaint ID ---
              if (searchMode == 0) ...[
                const Text(
                  'Complaint ID',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _complaintIdController,
                        decoration: InputDecoration(
                          hintText: 'Paste your complaint ID here',
                          prefixIcon: const Icon(
                            Icons.confirmation_number_rounded,
                            color: Color(0xFF00838F),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : _trackById,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00838F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Track'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ID Result
                if (complaintDetails != null)
                  _buildDetailCard(complaintDetails),
              ],

              // --- Search by Phone Number ---
              if (searchMode == 1) ...[
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneSearchController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter registered phone number',
                          prefixIcon: const Icon(
                            Icons.phone_rounded,
                            color: Color(0xFF00838F),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: isLoading ? null : _trackByPhone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00838F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Phone Results List
                if (phoneComplaints.isNotEmpty) ...[
                  Text(
                    '${phoneComplaints.length} complaint(s) found',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(phoneComplaints.map(
                    (complaint) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildDetailCard(complaint),
                    ),
                  )),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00838F) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Complaint Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    details['status'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(details['status'])),
                ),
                child: Text(
                  details['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(details['status']),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildDetailRow('Complaint ID', details['id']),
          _buildDetailRow('Category', details['category']),
          _buildDetailRow('Train Number', details['trainNumber']),
          _buildDetailRow('Coach Number', details['coachNumber']),
          _buildDetailRow('Phone Number', details['phoneNumber']),
          _buildDetailRow(
            'Description',
            details['description'],
            isMultiline: true,
          ),
          _buildDetailRow('Submitted On', details['submittedDate']),
          _buildDetailRow('Last Updated', details['lastUpdated']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
