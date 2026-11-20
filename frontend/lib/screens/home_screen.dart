import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/app_header.dart';
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

  final List<Map<String, dynamic>> _quickServices = const [
    {'title': 'Vedic', 'icon': Icons.brightness_high, 'color': Color(0xFFFFB300)},
    {'title': 'Tarot', 'icon': Icons.style, 'color': Color(0xFFFF7043)},
    {'title': 'Numerology', 'icon': Icons.pin, 'color': Color(0xFF42A5F5)},
    {'title': 'Vastu', 'icon': Icons.home_work, 'color': Color(0xFF66BB6A)},
    {'title': 'Kundli', 'icon': Icons.auto_stories, 'color': Color(0xFFAB47BC)},
  ];

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
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Astrologers'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'Kundli'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        ],
      ),
    );
  }

  Widget _buildHomeFeed(ThemeData theme, AppState appState) {
    return Scaffold(
      appBar: const AppHeader(title: 'Rini Pandit Astro'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promo Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x44FFB300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SPECIAL LAUNCH OFFER',
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'First Consultation with Rini Pandit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '25+ Yrs Experience • 100% Confidential',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.workspace_premium, size: 48, color: theme.colorScheme.primary),
                ],
              ),
            ),

            // Quick Service Category Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Explore Consultations',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _quickServices.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final s = _quickServices[index];
                  return GestureDetector(
                    onTap: () {
                      if (s['title'] == 'Kundli') {
                        setState(() => _currentIndex = 2);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AstrologerListScreen(initialCategory: s['title']),
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.surface,
                          child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s['title'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Daily Horoscope Card
            const HoroscopeCard(),
            const SizedBox(height: 16),

            // Top Verified Astrologers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Verified Astrologers',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: Text('View All', style: TextStyle(color: theme.colorScheme.primary)),
                  ),
                ],
              ),
            ),

            if (appState.astrologers.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else
              ...appState.astrologers.map((astro) => AstrologerCard(astrologer: astro)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
