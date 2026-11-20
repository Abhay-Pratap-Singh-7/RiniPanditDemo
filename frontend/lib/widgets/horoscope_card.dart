import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';

class HoroscopeCard extends StatefulWidget {
  const HoroscopeCard({super.key});

  @override
  State<HoroscopeCard> createState() => _HoroscopeCardState();
}

class _HoroscopeCardState extends State<HoroscopeCard> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  final List<Map<String, String>> _zodiacList = const [
    {'name': 'Aries', 'vedic': 'Mesh', 'dates': 'Mar 21 - Apr 19', 'element': 'Fire', 'key': 'aries'},
    {'name': 'Taurus', 'vedic': 'Vrishabha', 'dates': 'Apr 20 - May 20', 'element': 'Earth', 'key': 'taurus'},
    {'name': 'Gemini', 'vedic': 'Mithuna', 'dates': 'May 21 - Jun 20', 'element': 'Air', 'key': 'gemini'},
    {'name': 'Cancer', 'vedic': 'Karka', 'dates': 'Jun 21 - Jul 22', 'element': 'Water', 'key': 'cancer'},
    {'name': 'Leo', 'vedic': 'Simha', 'dates': 'Jul 23 - Aug 22', 'element': 'Fire', 'key': 'leo'},
    {'name': 'Virgo', 'vedic': 'Kanya', 'dates': 'Aug 23 - Sep 22', 'element': 'Earth', 'key': 'virgo'},
    {'name': 'Libra', 'vedic': 'Tula', 'dates': 'Sep 23 - Oct 22', 'element': 'Air', 'key': 'libra'},
    {'name': 'Scorpio', 'vedic': 'Vrishchika', 'dates': 'Oct 23 - Nov 21', 'element': 'Water', 'key': 'scorpio'},
    {'name': 'Sagittarius', 'vedic': 'Dhanu', 'dates': 'Nov 22 - Dec 21', 'element': 'Fire', 'key': 'sagittarius'},
    {'name': 'Capricorn', 'vedic': 'Makara', 'dates': 'Dec 22 - Jan 19', 'element': 'Earth', 'key': 'capricorn'},
    {'name': 'Aquarius', 'vedic': 'Kumbha', 'dates': 'Jan 20 - Feb 18', 'element': 'Air', 'key': 'aquarius'},
    {'name': 'Pisces', 'vedic': 'Meena', 'dates': 'Feb 19 - Mar 20', 'element': 'Water', 'key': 'pisces'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);

    // Auto-slide carousel every 4 seconds
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _zodiacList.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardPurple.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.cardLilac, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Daily Horoscope',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textWhite,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceTile,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Text(
                  '${_currentPage + 1} of 12',
                  style: const TextStyle(
                    color: AppTheme.cardLilac,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Horoscope Swipeable Carousel with 4-second auto slide
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _zodiacList.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final z = _zodiacList[index];
              final isCurrent = index == _currentPage;
              final signKey = z['key']!;
              final signHoroscope = appState.horoscopes[signKey];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withAlpha(235),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(
                    color: isCurrent ? AppTheme.cardLilac.withAlpha(180) : AppTheme.borderSubtle,
                    width: isCurrent ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent ? AppTheme.cardPurple.withAlpha(50) : Colors.black.withAlpha(60),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carousel Card Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Large Cut-Out Zodiac Medallion
                        Container(
                          width: 58,
                          height: 58,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.cardLilac, width: 1.8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.cardPurple.withAlpha(70),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/zodiac/$signKey.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: [
                                  Text(
                                    '${z["name"]} (${z["vedic"]})',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    ),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${z["dates"]} • ${z["element"]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceTile,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: const Text(
                            'Auto',
                            style: TextStyle(fontSize: 11, color: AppTheme.cardLilac),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Prediction Text from pre-fetched map
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            signHoroscope?.prediction ??
                                'Cosmic energy brings clarity in key pursuits and harmonious life balance today.',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.42,
                              color: Color(0xEEFFFFFF),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 3,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick Chips
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceTile,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            'Color: ${signHoroscope?.luckyColor ?? "Coral"}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.cardLilac,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceTile,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            'No: ${signHoroscope?.luckyNumber ?? 9}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.cardCoral,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Carousel Dot Indicators
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_zodiacList.length, (i) {
              final isCurrent = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isCurrent ? AppTheme.cardLilac : AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
