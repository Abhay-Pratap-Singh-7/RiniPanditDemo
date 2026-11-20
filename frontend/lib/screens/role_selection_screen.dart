import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return CosmicScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / Crest Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardPurple.withAlpha(50),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.cardLilac, width: 1.5),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppTheme.cardLilac, size: 40),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle with Text Wraps
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: const [
                    Text(
                      'Rini Pandit Astrology',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: const [
                    Text(
                      'Choose your role to enter the astrology platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Option 1: Client / Devotee
              _buildRoleCard(
                context: context,
                title: 'Client / Devotee',
                subtitle: 'Consult verified astrologers, read daily horoscopes, and calculate Janampatri birth charts.',
                assetPath: 'assets/icons/tile_zodiac.png',
                gradientColors: [AppTheme.cardPurple, AppTheme.surfaceDark],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen(initialRole: 'user')),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Option 2: Acharya / Pandit
              _buildRoleCard(
                context: context,
                title: 'Acharya / Pandit',
                subtitle: 'Manage consultation sessions, set availability, accept live chat requests, and track earnings.',
                assetPath: 'assets/icons/tile_vedic.png',
                gradientColors: [AppTheme.cardCoral, AppTheme.surfaceDark],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen(initialRole: 'pandit')),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Supabase Sign In / Register Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.cardLilac, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.lock_person_outlined, color: AppTheme.cardLilac, size: 20),
                label: const Text(
                  'Sign In / Register with Supabase',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              if (appState.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.cardPurple),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String assetPath,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withAlpha(220),
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 65,
              height: 65,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.person_pin_circle_outlined,
                  size: 50,
                  color: AppTheme.cardLilac,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    children: [
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.3,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.cardLilac, size: 16),
          ],
        ),
      ),
    );
  }
}
