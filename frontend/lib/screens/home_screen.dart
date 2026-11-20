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

  final List<Map<String, dynamic>> _navItems = const [
    {
      'label': 'Home',
      'icon': Icons.grid_view_outlined,
      'activeIcon': Icons.grid_view_rounded,
    },
    {
      'label': 'Astrologers',
      'icon': Icons.people_alt_outlined,
      'activeIcon': Icons.people_alt_rounded,
    },
    {
      'label': 'Kundli',
      'icon': Icons.auto_stories_outlined,
      'activeIcon': Icons.auto_stories_rounded,
    },
    {
      'label': 'Wallet',
      'icon': Icons.account_balance_wallet_outlined,
      'activeIcon': Icons.account_balance_wallet_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final pages = [
      _buildHomeFeed(appState),
      const AstrologerListScreen(),
      const KundliScreen(),
      const WalletScreen(),
    ];

    return CosmicScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(240),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.cardPurple.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _currentIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.cardPurple.withAlpha(50)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? Border.all(color: AppTheme.cardLilac.withAlpha(70), width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item['activeIcon'] : item['icon'],
                    size: 21,
                    color: isSelected ? AppTheme.cardLilac : AppTheme.textMuted,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      item['label'],
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textWhite,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHomeFeed(AppState appState) {
    return Column(
      children: [
        const AppHeader(title: 'Rini Astro'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top 3 Quick Feature Tiles (with transparent assets)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      QuickFeatureTile(
                        title: 'Vedic\nGuidance',
                        assetName: 'tile_vedic.png',
                        fallbackIcon: Icons.menu_book,
                        onTap: () {
                          setState(() => _currentIndex = 1);
                        },
                      ),
                      QuickFeatureTile(
                        title: 'Zodiac\nSigns',
                        assetName: 'tile_zodiac.png',
                        fallbackIcon: Icons.brightness_7_rounded,
                        onTap: () {
                          setState(() => _currentIndex = 2);
                        },
                      ),
                      QuickFeatureTile(
                        title: 'Kundli\nChart',
                        assetName: 'tile_kundli.png',
                        fallbackIcon: Icons.description_outlined,
                        onTap: () {
                          setState(() => _currentIndex = 2);
                        },
                      ),
                    ],
                  ),
                ),

                // Daily Horoscope Card Carousel
                const HoroscopeCard(),
                const SizedBox(height: 18),

                // 3 Large Featured Story Cards (app background color & under-text artwork)
                FeaturedStoryCard(
                  title: "Vedic Astrology Reading",
                  subtitle: "connects you with verified astrologers for guidance",
                  accentColor: AppTheme.cardPurple,
                  assetName: 'card_vedic_art.png',
                  fallbackIcon: Icons.menu_book_rounded,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),

                FeaturedStoryCard(
                  title: "Tarot & Subconscious Voice",
                  subtitle: "sheds light on the questions your inner soul is seeking",
                  accentColor: AppTheme.cardLilac,
                  assetName: 'card_tarot_art.png',
                  fallbackIcon: Icons.style,
                  onTap: () {
                    setState(() => _currentIndex = 1);
                  },
                ),

                FeaturedStoryCard(
                  title: "Cosmic Kundli Forecast",
                  subtitle: "unveils planetary houses, transits, and customized remedies",
                  accentColor: AppTheme.cardCoral,
                  assetName: 'card_kundli_art.png',
                  fallbackIcon: Icons.public_rounded,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                  },
                ),
                const SizedBox(height: 16),

                // Top Astrologers Section
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
        ),
      ],
    );
  }
}
