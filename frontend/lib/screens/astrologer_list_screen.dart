import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
import '../widgets/astrologer_card.dart';
import '../widgets/app_header.dart';

class AstrologerListScreen extends StatefulWidget {
  final String? initialCategory;

  const AstrologerListScreen({super.key, this.initialCategory});

  @override
  State<AstrologerListScreen> createState() => _AstrologerListScreenState();
}

class _AstrologerListScreenState extends State<AstrologerListScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Vedic', 'Tarot', 'Numerology', 'Vastu', 'Kundli'];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final canPop = Navigator.canPop(context);

    final filtered = _selectedCategory == 'All'
        ? appState.astrologers
        : appState.astrologers
            .where((a) => a.specialties
                .any((s) => s.toLowerCase().contains(_selectedCategory.toLowerCase())))
            .toList();

    final content = Column(
      children: [
        const AppHeader(title: 'Astrologer Marketplace'),

        // Filter Chips Row
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = cat);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.cardPurple : AppTheme.surfaceTile,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.cardPurple : AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Astrologer Cards List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No astrologers found in this category',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: canPop ? 30 : 110, top: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => AstrologerCard(astrologer: filtered[index]),
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
}
