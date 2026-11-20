import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final profile = appState.userProfile;
    final pandit = appState.currentPandit;
    final isPandit = appState.isPandit;

    final displayName = isPandit
        ? (pandit?.displayName.isNotEmpty == true ? pandit!.displayName : 'Acharya')
        : (profile?.fullName.isNotEmpty == true ? profile!.fullName : 'Devotee');

    final email = appState.currentUser?['email'] as String? ?? 'Authenticated User';
    final phone = profile?.phone.isNotEmpty == true
        ? profile!.phone
        : (appState.currentUser?['phone'] as String? ?? 'Not provided');

    return CosmicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textWhite,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Avatar & Name Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withAlpha(220),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppTheme.cardPurple.withAlpha(50),
                      backgroundImage: profile?.avatarUrl.isNotEmpty == true
                          ? NetworkImage(profile!.avatarUrl)
                          : null,
                      child: profile?.avatarUrl.isEmpty != false
                          ? const Icon(Icons.person, size: 44, color: AppTheme.cardLilac)
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textWhite,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPandit
                            ? AppTheme.cardCoral.withAlpha(35)
                            : AppTheme.cardPurple.withAlpha(45),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPandit ? AppTheme.cardCoral : AppTheme.cardLilac,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isPandit ? 'Acharya / Pandit' : 'Client / Devotee',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPandit ? AppTheme.cardCoral : AppTheme.cardLilac,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Account Details List
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withAlpha(220),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: email,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 20),
                    _buildInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: phone,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 20),
                    _buildInfoTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet Balance',
                      value: '₹${appState.walletBalance.toStringAsFixed(0)}',
                    ),
                    if (isPandit && pandit != null) ...[
                      const Divider(color: AppTheme.borderSubtle, height: 20),
                      _buildInfoTile(
                        icon: Icons.currency_rupee,
                        label: 'Consultation Rate',
                        value: '₹${pandit.ratePerMinute.toStringAsFixed(0)} / min',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC0392B).withAlpha(220),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE74C3C), width: 1),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.surfaceDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: AppTheme.borderSubtle),
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w700),
                        ),
                        content: const Text(
                          'Are you sure you want to log out of your account?',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Log Out', style: TextStyle(color: Color(0xFFE74C3C), fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await appState.logout();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.cardPurple.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.cardLilac),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
