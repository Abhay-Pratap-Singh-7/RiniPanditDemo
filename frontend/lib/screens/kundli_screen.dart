import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';

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
  final String _gender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _tobController.dispose();
    _pobController.dispose();
    super.dispose();
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

    return CosmicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Free Kundli Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Card
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withAlpha(220),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardPurple.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_stories, color: AppTheme.cardLilac, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Enter Birth Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dobController,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth (YYYY-MM-DD)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _tobController,
                          decoration: const InputDecoration(
                            labelText: 'Time of Birth (HH:MM)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _pobController,
                    decoration: const InputDecoration(labelText: 'Place of Birth (City)'),
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: appState.isLoading ? null : _generateKundli,
                    child: appState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Calculate Janampatri & Doshas'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Results Section
            if (kundli != null) ...[
              const Text(
                'Birth Chart Summary',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Sign Badges Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _buildSignBadge('Ascendant (Lagna)', kundli.ascendant),
                  _buildSignBadge('Moon Sign (Rashi)', kundli.moonSign),
                  _buildSignBadge('Sun Sign (Surya)', kundli.sunSign),
                  _buildSignBadge('Nakshatra', kundli.nakshatra),
                ],
              ),
              const SizedBox(height: 16),

              // Dosha Card
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: kundli.manglik ? const Color(0x22EF4444) : AppTheme.surfaceDark.withAlpha(220),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(
                    color: kundli.manglik ? Colors.redAccent.withAlpha(100) : AppTheme.borderSubtle,
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          kundli.manglik ? 'Manglik Dosha Detected' : 'Manglik Dosha: Absent',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        Text(
                          'Remedy: ${kundli.remedy}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.3),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Planetary Positions
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withAlpha(220),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Planetary Alignments (Graha Sthiti)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ...kundli.planetaryPositions.map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.planet, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                            Text(
                              '${p.sign} (${p.degree})',
                              style: const TextStyle(color: AppTheme.cardLilac, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceTile,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(p.status, style: const TextStyle(fontSize: 11, color: AppTheme.textWhite)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Predictions
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withAlpha(220),
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
                          'Astrological Guidance & Transit',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: [
                        Text(
                          kundli.prediction,
                          style: const TextStyle(fontSize: 13, height: 1.45, color: Color(0xEEFFFFFF)),
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
    );
  }

  Widget _buildSignBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.cardLilac,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
