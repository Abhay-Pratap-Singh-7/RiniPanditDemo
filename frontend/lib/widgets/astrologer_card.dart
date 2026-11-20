import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with Online Status Indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primary.withAlpha(50),
                  backgroundImage: astrologer.avatarUrl.isNotEmpty
                      ? NetworkImage(astrologer.avatarUrl)
                      : null,
                  child: astrologer.avatarUrl.isEmpty
                      ? Icon(Icons.person, size: 36, color: theme.colorScheme.primary)
                      : null,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: astrologer.isOnline ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          astrologer.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            astrologer.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Specialties
                  Text(
                    astrologer.specialties.join(' • '),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Languages & Exp
                  Text(
                    '${astrologer.languages.join(", ")} | ${astrologer.experienceYears}+ yrs',
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withAlpha(180)),
                  ),
                  const SizedBox(height: 8),

                  // Price & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${astrologer.ratePerMinute.toStringAsFixed(0)}/min',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat', style: TextStyle(fontSize: 13)),
                        onPressed: () {
                          if (appState.walletBalance < astrologer.ratePerMinute) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Minimum balance of ₹${astrologer.ratePerMinute.toStringAsFixed(0)} required. Please recharge wallet.',
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
      ),
    );
  }
}
