import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
import '../widgets/app_header.dart';

class KundliScreen extends StatefulWidget {
  const KundliScreen({super.key});

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> {
  final _nameController = TextEditingController(text: 'Rahul Sharma');
  final _dobController = TextEditingController(text: '1995-08-15');
  final _tobController = TextEditingController(text: '07:30');
  final _pobController = TextEditingController(text: 'New Delhi');
  String _gender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateTime.tryParse(_dobController.text) ?? DateTime(1995, 8, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.cardPurple,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final parts = _tobController.text.split(':');
    final initialTime = parts.length == 2
        ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 7, minute: int.tryParse(parts[1]) ?? 30)
        : const TimeOfDay(hour: 7, minute: 30);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.cardPurple,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tobController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  void _generateKundli() {
    context.read<AppState>().generateKundli({
      'name': _nameController.text,
      'gender': _gender,
      'dob': _dobController.text,
      'tob': _tobController.text,
      'pobCity': _pobController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final kundli = appState.currentKundli;
    final canPop = Navigator.canPop(context);

    final content = Column(
      children: [
        const AppHeader(title: 'Vedic Kundli'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, canPop ? 30 : 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Hero Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Birth Chart & Janampatri',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textWhite,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Instant planetary positions, Manglik Dosha detection, and remedial guidance based on authentic Vedic principles.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppTheme.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: Image.asset(
                          'assets/cards/card_kundli_art.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.auto_stories_rounded,
                            size: 54,
                            color: AppTheme.cardCoral,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Input Form Card
                Container(
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppTheme.cardPurple.withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.edit_calendar_rounded, color: AppTheme.cardLilac, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Enter Birth Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.cardLilac, size: 20),
                          filled: true,
                          fillColor: AppTheme.surfaceTile,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Gender Selection
                      Row(
                        children: ['male', 'female', 'other'].map((g) {
                          final isSelected = _gender == g;
                          final label = g[0].toUpperCase() + g.substring(1);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _gender = g),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.cardPurple : AppTheme.surfaceTile,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.cardLilac : AppTheme.borderSubtle,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppTheme.textMuted,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // DOB and TOB in Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _dobController,
                                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppTheme.cardLilac, size: 18),
                                    filled: true,
                                    fillColor: AppTheme.surfaceTile,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  controller: _tobController,
                                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                                  decoration: InputDecoration(
                                    labelText: 'Time of Birth',
                                    prefixIcon: const Icon(Icons.access_time_rounded, color: AppTheme.cardLilac, size: 18),
                                    filled: true,
                                    fillColor: AppTheme.surfaceTile,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: AppTheme.borderSubtle),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Place of Birth
                      TextField(
                        controller: _pobController,
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Place of Birth (City)',
                          prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.cardLilac, size: 20),
                          filled: true,
                          fillColor: AppTheme.surfaceTile,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cardPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: appState.isLoading ? null : _generateKundli,
                          child: appState.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Calculate Janampatri & Doshas',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kundli Results Section
                if (kundli != null) ...[
                  const Text(
                    'Core Planetary Pillars',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.textWhite,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4 Core Sign Badges
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildSignBadge('Ascendant (Lagna)', kundli.ascendant, Icons.north_east_rounded),
                      _buildSignBadge('Moon Sign (Rashi)', kundli.moonSign, Icons.nightlight_round),
                      _buildSignBadge('Sun Sign (Surya)', kundli.sunSign, Icons.wb_sunny_rounded),
                      _buildSignBadge('Nakshatra', kundli.nakshatra, Icons.stars_rounded),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Kundli Houses 12-Bhava Chart Visualizer
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.dashboard_customize_outlined, color: AppTheme.cardLilac, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Lagna Kundli Chart (Bhavas)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textWhite,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            final houseNum = index + 1;
                            final isLagna = houseNum == 1;
                            final signName = _getHouseSign(kundli.ascendant, index);

                            return Container(
                              decoration: BoxDecoration(
                                color: isLagna
                                    ? AppTheme.cardPurple.withAlpha(50)
                                    : AppTheme.surfaceTile,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLagna ? AppTheme.cardLilac : AppTheme.borderSubtle,
                                  width: isLagna ? 1.5 : 0.8,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'H$houseNum',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isLagna ? AppTheme.cardLilac : AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    signName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textWhite,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dosha Analysis Card
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: kundli.manglik ? const Color(0x28EF4444) : AppTheme.surfaceDark,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(
                        color: kundli.manglik ? Colors.redAccent.withAlpha(120) : AppTheme.borderSubtle,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              kundli.manglik ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: kundli.manglik ? Colors.redAccent : AppTheme.accentCyan,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              kundli.manglik ? 'Manglik Dosha Detected' : 'Manglik Dosha: Absent',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          children: [
                            Text(
                              'Remedial Action: ${kundli.remedy}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                height: 1.35,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Planetary Alignments (Graha Sthiti) Table
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Planetary Alignments (Graha Sthiti)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...kundli.planetaryPositions.map(
                          (p) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceTile,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderSubtle, width: 0.8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p.planet,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13),
                                ),
                                Text(
                                  '${p.sign} (${p.degree})',
                                  style: const TextStyle(color: AppTheme.cardLilac, fontSize: 12.5),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardPurple.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.status,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textWhite, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Predictions & Astrological Guidance
                  Container(
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.psychology_outlined, color: AppTheme.cardLilac),
                            SizedBox(width: 8),
                            Text(
                              'Vedic Guidance & Transit Forecast',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: [
                            Text(
                              kundli.prediction,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: Color(0xEEFFFFFF),
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    if (canPop) {
      return CosmicScaffold(
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  String _getHouseSign(String ascendant, int houseIndex) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    final ascIndex = signs.indexWhere((s) => s.toLowerCase() == ascendant.toLowerCase());
    if (ascIndex == -1) return signs[houseIndex % 12];
    return signs[(ascIndex + houseIndex) % 12];
  }

  Widget _buildSignBadge(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.cardPurple.withAlpha(35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.cardLilac),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
