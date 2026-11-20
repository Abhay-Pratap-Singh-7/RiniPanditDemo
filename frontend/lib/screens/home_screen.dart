import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
import '../widgets/quick_feature_tile.dart';
import '../widgets/featured_story_card.dart';
import '../widgets/horoscope_card.dart';
import '../widgets/astrologer_card.dart';
import 'astrologer_list_screen.dart';
import 'kundli_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    final pages = [
      _buildHomeFeed(theme, appState),
      const AstrologerListScreen(),
      const KundliScreen(),
      const WalletScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Astrologers'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories_outlined), label: 'Kundli'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
        ],
      ),
    );
  }

  Widget _buildHomeFeed(ThemeData theme, AppState appState) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: const AppHeader(title: 'Rini Astro'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Hero Title (as in reference image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: const [
                    Text(
                      'Cosmic Insight\nand\ndaily horoscope',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textWhite,
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),

            // Top 3 Quick Feature Tiles (as in reference image)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  QuickFeatureTile(
                    title: 'Affirmation for You',
                    assetName: 'tile_affirmation.png',
                    fallbackIcon: Icons.spa_outlined,
                    onTap: () {
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  QuickFeatureTile(
                    title: 'Zodiac Signs',
                    assetName: 'tile_zodiac.png',
                    fallbackIcon: Icons.nightlight_round,
                    onTap: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  QuickFeatureTile(
                    title: 'Lunar Calendar',
                    assetName: 'tile_calendar.png',
                    fallbackIcon: Icons.calendar_month_outlined,
                    onTap: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3 Large Featured Story Cards (as in reference image)
            FeaturedStoryCard(
              title: "Vedic Astrology Guidance",
              subtitle: "tells you about your destiny and life purpose",
              backgroundColor: AppTheme.cardPurple,
              assetName: 'card_vedic_art.png',
              fallbackIcon: Icons.self_improvement,
              onTap: () {
                setState(() => _currentIndex = 1);
              },
            ),

            FeaturedStoryCard(
              title: "Subconscious Voice",
              subtitle: "sheds light on the problems your inner mind is speaking about",
              backgroundColor: AppTheme.cardLilac,
              assetName: 'card_tarot_art.png',
              fallbackIcon: Icons.menu_book_rounded,
              onTap: () {
                setState(() => _currentIndex = 1);
              },
            ),

            FeaturedStoryCard(
              title: "Cosmic Predictions",
              subtitle: "tells you about upcoming planetary events and transits",
              backgroundColor: AppTheme.cardCoral,
              assetName: 'card_kundli_art.png',
              fallbackIcon: Icons.public_rounded,
              onTap: () {
                setState(() => _currentIndex = 2);
              },
            ),
            const SizedBox(height: 16),

            // Daily Horoscope Card
            const HoroscopeCard(),
            const SizedBox(height: 18),

            // Top Verified Astrologers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Astrologers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.cardLilac,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (appState.astrologers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppTheme.cardPurple),
                ),
              )
            else
              ...appState.astrologers.map((astro) => AstrologerCard(astrologer: astro)),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
