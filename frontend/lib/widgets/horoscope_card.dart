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
    {'name': 'Aries', 'key': 'aries'},
    {'name': 'Taurus', 'key': 'taurus'},
    {'name': 'Gemini', 'key': 'gemini'},
    {'name': 'Cancer', 'key': 'cancer'},
    {'name': 'Leo', 'key': 'leo'},
    {'name': 'Virgo', 'key': 'virgo'},
    {'name': 'Libra', 'key': 'libra'},
    {'name': 'Scorpio', 'key': 'scorpio'},
    {'name': 'Sagittarius', 'key': 'sagittarius'},
    {'name': 'Capricorn', 'key': 'capricorn'},
    {'name': 'Aquarius', 'key': 'aquarius'},
    {'name': 'Pisces', 'key': 'pisces'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final horoscope = appState.currentHoroscope;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceTile,
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 14),

          // Horizontal Zodiac Signs List
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _zodiacList.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final z = _zodiacList[index];
                final isSelected = z['key'] == _selectedSign;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedSign = z['key']!);
                    appState.loadHoroscope(z['key']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.cardPurple : AppTheme.surfaceTile,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.cardPurple : AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        z['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          if (horoscope != null) ...[
            Wrap(
              children: [
                Text(
                  horoscope.prediction,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xDDF8FAFC),
                  ),
                  softWrap: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceTile,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1),
                  ),
                  child: Text(
                    'Color: ${horoscope.luckyColor}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.cardLilac, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceTile,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1),
                  ),
                  child: Text(
                    'Number: ${horoscope.luckyNumber}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.cardCoral, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppTheme.cardPurple),
              ),
            ),
        ],
      ),
    );
  }
}
