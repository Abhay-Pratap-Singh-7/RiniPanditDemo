import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/cosmic_scaffold.dart';
import 'pandit_dashboard_screen.dart';

class PanditProfileSetupScreen extends StatefulWidget {
  const PanditProfileSetupScreen({super.key});

  @override
  State<PanditProfileSetupScreen> createState() => _PanditProfileSetupScreenState();
}

class _PanditProfileSetupScreenState extends State<PanditProfileSetupScreen> {
  final _rateController = TextEditingController(text: '25');
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController(text: '5');

  final List<String> _availableSpecialties = const [
    'Vedic Astrology',
    'Kundli Matching',
    'Tarot Reading',
    'Numerology',
    'Vastu Shastra',
    'Palmistry',
    'Prashna Kundli',
    'Gemology',
    'Lal Kitab',
    'Face Reading',
  ];

  final Set<String> _selectedSpecialties = {'Vedic Astrology', 'Kundli Matching'};

  final List<double> _quickRates = const [15, 25, 35, 50, 75, 100];

  @override
  void dispose() {
    _rateController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final appState = context.read<AppState>();
    final rate = double.tryParse(_rateController.text.trim()) ?? 25.0;
    final exp = int.tryParse(_experienceController.text.trim()) ?? 5;
    final bio = _bioController.text.trim();

    if (_selectedSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one astrology specialty.')),
      );
      return;
    }

    final success = await appState.updatePanditProfile(
      ratePerMinute: rate,
      bio: bio.isNotEmpty ? bio : 'Certified Astrologer specializing in ${_selectedSpecialties.join(", ")}.',
      specialties: _selectedSpecialties.toList(),
      experienceYears: exp,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation profile configured successfully.'),
          backgroundColor: AppTheme.cardPurple,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PanditDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appState.errorMessage ?? 'Failed to save consultation profile.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _skipToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PanditDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return CosmicScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Setup Pandit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textWhite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skipToDashboard,
            child: const Text(
              'Skip',
              style: TextStyle(color: AppTheme.cardLilac, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark.withAlpha(220),
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.cardPurple.withAlpha(45),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardLilac, width: 1),
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppTheme.cardLilac, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${appState.userProfile?.fullName ?? "Acharya"}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Configure your consultation details for devotees.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Rate Per Minute
              const Text(
                'Consultation Rate (₹ / min)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.currency_rupee, color: AppTheme.accentCyan, size: 20),
                  suffixText: '/ minute',
                  suffixStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  hintText: '25',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick Rate Selectors
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickRates.map((rate) {
                  final isSelected = _rateController.text.trim() == rate.toStringAsFixed(0);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rateController.text = rate.toStringAsFixed(0);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.cardPurple : AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppTheme.cardLilac : AppTheme.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '₹${rate.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Section 2: Specialties
              const Text(
                'Astrology Specialties',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSpecialties.map((specialty) {
                  final isSelected = _selectedSpecialties.contains(specialty);
                  return FilterChip(
                    label: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecialties.add(specialty);
                        } else {
                          if (_selectedSpecialties.length > 1) {
                            _selectedSpecialties.remove(specialty);
                          }
                        }
                      });
                    },
                    backgroundColor: AppTheme.surfaceDark,
                    selectedColor: AppTheme.cardPurple,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppTheme.cardLilac : AppTheme.borderSubtle,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Section 3: Experience Years
              const Text(
                'Years of Experience',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.history_edu, color: AppTheme.cardLilac, size: 20),
                  suffixText: 'years',
                  suffixStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  hintText: '5',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Section 4: Bio / Guidance Background
              const Text(
                'Bio & Guidance Background',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Share your background, guidance approach, and spiritual lineage...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cardPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: appState.isLoading ? null : _handleSave,
                  child: appState.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save & Enter Portal',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
