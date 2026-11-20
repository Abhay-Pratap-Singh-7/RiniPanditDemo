import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';

class HoroscopeCard extends StatefulWidget {
  const HoroscopeCard({super.key});

  @override
  State<HoroscopeCard> createState() => _HoroscopeCardState();
}

class _HoroscopeCardState extends State<HoroscopeCard> {
  String _selectedSign = 'aries';

  final List<Map<String, String>> _zodiacList = const [
    {'name': 'Aries', 'vedic': 'Mesh', 'dates': 'Mar 21 - Apr 19', 'key': 'aries'},
    {'name': 'Taurus', 'vedic': 'Vrishabha', 'dates': 'Apr 20 - May 20', 'key': 'taurus'},
    {'name': 'Gemini', 'vedic': 'Mithuna', 'dates': 'May 21 - Jun 20', 'key': 'gemini'},
    {'name': 'Cancer', 'vedic': 'Karka', 'dates': 'Jun 21 - Jul 22', 'key': 'cancer'},
    {'name': 'Leo', 'vedic': 'Simha', 'dates': 'Jul 23 - Aug 22', 'key': 'leo'},
    {'name': 'Virgo', 'vedic': 'Kanya', 'dates': 'Aug 23 - Sep 22', 'key': 'virgo'},
    {'name': 'Libra', 'vedic': 'Tula', 'dates': 'Sep 23 - Oct 22', 'key': 'libra'},
    {'name': 'Scorpio', 'vedic': 'Vrishchika', 'dates': 'Oct 23 - Nov 21', 'key': 'scorpio'},
    {'name': 'Sagittarius', 'vedic': 'Dhanu', 'dates': 'Nov 22 - Dec 21', 'key': 'sagittarius'},
    {'name': 'Capricorn', 'vedic': 'Makara', 'dates': 'Dec 22 - Jan 19', 'key': 'capricorn'},
    {'name': 'Aquarius', 'vedic': 'Kumbha', 'dates': 'Jan 20 - Feb 18', 'key': 'aquarius'},
    {'name': 'Pisces', 'vedic': 'Meena', 'dates': 'Feb 19 - Mar 20', 'key': 'pisces'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final horoscope = appState.currentHoroscope;
    final activeZodiac = _zodiacList.firstWhere(
      (z) => z['key'] == _selectedSign,
      orElse: () => _zodiacList[0],
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(220),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 12),
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
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: AppTheme.cardLilac,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 12 Zodiac Illustrated Medallions Carousel
          SizedBox(
            height: 94,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _zodiacList.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final z = _zodiacList[index];
                final isSelected = z['key'] == _selectedSign;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedSign = z['key']!);
                    appState.loadHoroscope(z['key']!);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.cardLilac : AppTheme.borderSubtle,
                            width: isSelected ? 2.2 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.cardPurple.withAlpha(120),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/zodiac/${z["key"]}.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.stars,
                              color: AppTheme.cardLilac,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        z['name']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppTheme.textWhite : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Divider(color: Color(0x22FFFFFF), height: 16),

          // Reimagined Active Sign Spotlight
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large Zodiac Medallion
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardLilac, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cardPurple.withAlpha(80),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/zodiac/$_selectedSign.png',
                          fit: BoxFit.cover,
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
                                '${activeZodiac["name"]} (${activeZodiac["vedic"]})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            activeZodiac['dates']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceTile,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: Text(
                                  'Lucky: ${horoscope?.luckyColor ?? "Coral"}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.cardLilac,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceTile,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: Text(
                                  'No: ${horoscope?.luckyNumber ?? "9"}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.cardCoral,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Prediction Text with text wraps
                if (horoscope != null)
                  Wrap(
                    children: [
                      Text(
                        horoscope.prediction,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: Color(0xEEFFFFFF),
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                      ),
                    ],
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: AppTheme.cardPurple),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
