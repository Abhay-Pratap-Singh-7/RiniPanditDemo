import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HoroscopeCard extends StatefulWidget {
  const HoroscopeCard({super.key});

  @override
  State<HoroscopeCard> createState() => _HoroscopeCardState();
}

class _HoroscopeCardState extends State<HoroscopeCard> {
  String _selectedSign = 'aries';

  final List<Map<String, String>> _zodiacList = const [
    {'name': 'Aries', 'key': 'aries', 'symbol': '♈'},
    {'name': 'Taurus', 'key': 'taurus', 'symbol': '♉'},
    {'name': 'Gemini', 'key': 'gemini', 'symbol': '♊'},
    {'name': 'Cancer', 'key': 'cancer', 'symbol': '♋'},
    {'name': 'Leo', 'key': 'leo', 'symbol': '♌'},
    {'name': 'Virgo', 'key': 'virgo', 'symbol': '♍'},
    {'name': 'Libra', 'key': 'libra', 'symbol': '♎'},
    {'name': 'Scorpio', 'key': 'scorpio', 'symbol': '♏'},
    {'name': 'Sagittarius', 'key': 'sagittarius', 'symbol': '♐'},
    {'name': 'Capricorn', 'key': 'capricorn', 'symbol': '♑'},
    {'name': 'Aquarius', 'key': 'aquarius', 'symbol': '♒'},
    {'name': 'Pisces', 'key': 'pisces', 'symbol': '♓'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final horoscope = appState.currentHoroscope;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Daily Horoscope',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                Text(
                  'Today',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Zodiac Signs List
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _zodiacList.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final z = _zodiacList[index];
                  final isSelected = z['key'] == _selectedSign;

                  return ChoiceChip(
                    label: Text('${z['symbol']} ${z['name']}'),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedSign = z['key']!);
                        appState.loadHoroscope(z['key']!);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            if (horoscope != null) ...[
              Text(
                horoscope.prediction,
                style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lucky Color: ${horoscope.luckyColor}',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lucky No: ${horoscope.luckyNumber}',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
