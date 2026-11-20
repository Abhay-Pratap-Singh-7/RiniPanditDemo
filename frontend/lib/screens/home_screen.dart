import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
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
    final appState = context.watch<AppState>();

    final pages = [
      _buildHomeFeed(appState),
      const AstrologerListScreen(),
      const KundliScreen(),
      const WalletScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
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

  Widget _buildHomeFeed(AppState appState) {
    return CosmicScaffold(
      appBar: const AppHeader(title: 'Rini Astro'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 3 Quick Feature Tiles (with cut out transparent assets)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  QuickFeatureTile(
                    title: 'Vedic Guidance',
                    assetName: 'tile_vedic.png',
                    fallbackIcon: Icons.menu_book,
                    onTap: () {
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  QuickFeatureTile(
                    title: 'Zodiac Signs',
                    assetName: 'tile_zodiac.png',
                    fallbackIcon: Icons.brightness_7_rounded,
                    onTap: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  QuickFeatureTile(
                    title: 'Kundli Chart',
                    assetName: 'tile_kundli.png',
                    fallbackIcon: Icons.description_outlined,
                    onTap: () {
                      setState(() => _currentIndex = 2);
                    },
                  ),
                ],
              ),
            ),

            // 3 Large Featured Story Cards (with cut out transparent assets)
            FeaturedStoryCard(
              title: "Vedic Astrology Reading",
              subtitle: "connects you with verified astrologers for guidance",
              backgroundColor: AppTheme.cardPurple,
              assetName: 'card_vedic_art.png',
              fallbackIcon: Icons.menu_book_rounded,
              onTap: () {
                setState(() => _currentIndex = 1);
              },
            ),

            FeaturedStoryCard(
              title: "Tarot & Subconscious Voice",
              subtitle: "sheds light on the questions your inner soul is seeking",
              backgroundColor: AppTheme.cardLilac,
              assetName: 'card_tarot_art.png',
              fallbackIcon: Icons.style,
              onTap: () {
                setState(() => _currentIndex = 1);
              },
            ),

            FeaturedStoryCard(
              title: "Cosmic Kundli Forecast",
              subtitle: "unveils planetary houses, transits, and customized remedies",
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
