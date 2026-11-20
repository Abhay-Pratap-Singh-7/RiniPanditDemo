import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

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
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final kundli = appState.currentKundli;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Kundli Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_stories, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Enter Birth Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: appState.isLoading ? null : _generateKundli,
                      child: appState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text('Calculate Janampatri & Dosha'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Section
            if (kundli != null) ...[
              Text(
                'Birth Chart Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                  _buildSignBadge('Ascendant (Lagna)', kundli.ascendant, theme),
                  _buildSignBadge('Moon Sign (Rashi)', kundli.moonSign, theme),
                  _buildSignBadge('Sun Sign (Surya)', kundli.sunSign, theme),
                  _buildSignBadge('Nakshatra', kundli.nakshatra, theme),
                ],
              ),
              const SizedBox(height: 16),

              // Dosha Card
              Card(
                color: kundli.manglik ? const Color(0x33EF4444) : theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            kundli.manglik ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: kundli.manglik ? Colors.redAccent : Colors.greenAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            kundli.manglik ? 'Manglik Dosha Detected' : 'Manglik Dosha: Absent',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Remedy: ${kundli.remedy}',
                        style: const TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Planetary Positions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Planetary Alignments (Graha Sthiti)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...kundli.planetaryPositions.map(
                        (p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p.planet, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                '${p.sign} (${p.degree})',
                                style: TextStyle(color: theme.colorScheme.primary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(p.status, style: const TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Predictions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Astrological Guidance & Transit',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kundli.prediction,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignBadge(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
