import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/astrologer.dart';
import '../providers/app_state.dart';
import '../screens/chat_consultation_screen.dart';

class AstrologerCard extends StatelessWidget {
  final Astrologer astrologer;

  const AstrologerCard({super.key, required this.astrologer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.read<AppState>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with Online Status
          Stack(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppTheme.cardPurple.withAlpha(40),
                backgroundImage: astrologer.avatarUrl.isNotEmpty
                    ? NetworkImage(astrologer.avatarUrl)
                    : null,
                child: astrologer.avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 32, color: AppTheme.cardLilac)
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: astrologer.isOnline ? AppTheme.accentCyan : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.surfaceDark, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        children: [
                          Text(
                            astrologer.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textWhite,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceTile,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            astrologer.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Wrapped Specialties
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: astrologer.specialties.take(3).map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.cardPurple.withAlpha(35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textPurpleLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Experience & Language
                Wrap(
                  children: [
                    Text(
                      '${astrologer.languages.join(", ")} • ${astrologer.experienceYears}+ years exp',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rate & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${astrologer.ratePerMinute.toStringAsFixed(0)} / min',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 15, color: Colors.white),
                      label: const Text('Consult', style: TextStyle(fontSize: 13, color: Colors.white)),
                      onPressed: () {
                        if (appState.walletBalance < astrologer.ratePerMinute) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Minimum balance of ₹${astrologer.ratePerMinute.toStringAsFixed(0)} required to start consultation.',
                              ),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                          return;
                        }

                        appState.startConsultation(astrologer.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatConsultationScreen(astrologer: astrologer),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
