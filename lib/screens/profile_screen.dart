import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'qr_screen.dart';
import 'sections_screen.dart';
import '../services/api_service.dart';
import '../models/instructor_profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isSaving = false;
  bool _isLoading = true;
  InstructorProfile? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getInstructorProfile();
      
      if (response['success'] == true && response['data'] != null) {
        final profile = InstructorProfile.fromJson(response['data']);
        setState(() {
          _profile = profile;
          _firstnameController.text = profile.firstname ?? '';
          _lastnameController.text = profile.lastname ?? '';
          _emailController.text = profile.email;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      // Parse the date string - assuming format like "2025-10-19T03:40.143832"
      final date = DateTime.parse(dateString.replaceAll('.', ':'));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isSaving = true);

    try {
      // Call the API to update the profile
      final response = await _apiService.updateInstructorProfile(
        instructorId: _profile!.id,
        email: _emailController.text.trim(),
        firstname: _firstnameController.text.trim().isEmpty ? null : _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim().isEmpty ? null : _lastnameController.text.trim(),
      );

      if (!mounted) return;

      if (response['success'] == true) {
        // Reload the profile to get updated data
        await _loadProfile();
        
        // Close the modal
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _openEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    left: 20,
                    right: 20,
                    top: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Edit Profile Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E3A8A),
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text('First Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1E3A8A))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your first name',
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E3A8A)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Last Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1E3A8A))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your last name',
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1E3A8A)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Email Address', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1E3A8A))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1E3A8A)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2)),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            return emailRegex.hasMatch(v) ? null : 'Enter a valid email';
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1E3A8A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E3A8A))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Image.asset('lib/images/aclc_logo.png',width: 50, height: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Profile',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                      ),
                    ),
                    const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                  ],
                ),
              ),

              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                            ),
                          )
                        : _errorMessage != null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 60,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton(
                                        onPressed: _loadProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E3A8A),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Polished profile card
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Avatar (no container background)
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF3B4FA1),
                                          ),
                                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                                        ),
                                        const SizedBox(width: 12),
                                        // Name + email
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _profile?.fullName ?? 'Loading...',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _profile?.email ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _openEditModal,
                                          icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A), size: 20),
                                          splashRadius: 18,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),
                                    Text('Profile Information', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A), fontSize: 20)),
                                    const SizedBox(height: 10),
                                    _buildInfoCard('ID', _profile?.id.toString() ?? 'N/A'),
                                    const SizedBox(height: 10),
                                    _buildInfoCard('First Name', _profile?.firstname ?? 'Not set'),
                                    const SizedBox(height: 10),
                                    _buildInfoCard('Last Name', _profile?.lastname ?? 'Not set'),
                                    const SizedBox(height: 10),
                                    _buildInfoCard('Email', _profile?.email ?? 'N/A'),
                                    const SizedBox(height: 10),
                                    _buildInfoCard('Created At', _formatDate(_profile?.createdAt)),
                                    const SizedBox(height: 10),
                                    _buildInfoCard('Updated At', _formatDate(_profile?.updatedAt)),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: 4,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardScreen()));
            } else if (index == 1) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AttendanceScreen()));
            } else if (index == 2) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => QrScreen()));
            } else if (index == 3) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SectionsScreen()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Attendance'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR'),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Sections'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

