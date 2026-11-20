import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _tobController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().userProfile;
    _nameController = TextEditingController(text: profile?.fullName ?? 'Rahul Sharma');
    _phoneController = TextEditingController(text: profile?.phone ?? '+919876543210');
    _dobController = TextEditingController(text: profile?.dob ?? '1995-08-15');
    _tobController = TextEditingController(text: profile?.tob ?? '07:30');
    _cityController = TextEditingController(text: profile?.pobCity ?? 'New Delhi');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('My Profile & Birth Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.cardPurple,
                    backgroundImage: appState.userProfile?.avatarUrl.isNotEmpty == true
                        ? NetworkImage(appState.userProfile!.avatarUrl)
                        : null,
                    child: appState.userProfile?.avatarUrl.isEmpty != false
                        ? const Icon(Icons.person, size: 48, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppTheme.cardCoral,
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Card
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: AppTheme.cardRadius,
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _phoneController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number (Verified)',
                      prefixIcon: Icon(Icons.verified_user_outlined, color: AppTheme.accentCyan, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dobController,
                          decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _tobController,
                          decoration: const InputDecoration(labelText: 'Time of Birth (HH:MM)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Place of Birth (City)'),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      await appState.updateProfile({
                        'full_name': _nameController.text,
                        'dob': _dobController.text,
                        'tob': _tobController.text,
                        'pob_city': _cityController.text,
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile and birth details updated successfully.'),
                          backgroundColor: AppTheme.cardPurple,
                        ),
                      );
                    },
                    child: const Text('Save Birth Details'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
