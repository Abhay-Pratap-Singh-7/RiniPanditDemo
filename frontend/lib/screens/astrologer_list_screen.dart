import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
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
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    final filtered = _selectedCategory == 'All'
        ? appState.astrologers
        : appState.astrologers
            .where((a) => a.specialties
                .any((s) => s.toLowerCase().contains(_selectedCategory.toLowerCase())))
            .toList();

    return Scaffold(
      appBar: const AppHeader(title: 'Astrologer Marketplace'),
      body: Column(
        children: [
          // Filter Chips
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

                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (val) {
                    setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No astrologers found in this category', style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => AstrologerCard(astrologer: filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
