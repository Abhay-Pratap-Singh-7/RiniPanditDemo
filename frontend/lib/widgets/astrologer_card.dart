import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/astrologer.dart';
import '../providers/app_state.dart';
import '../screens/chat_consultation_screen.dart';

class AstrologerCard extends StatefulWidget {
  final Astrologer astrologer;

  const AstrologerCard({super.key, required this.astrologer});

  @override
  State<AstrologerCard> createState() => _AstrologerCardState();
}

class _AstrologerCardState extends State<AstrologerCard> {
  bool _isExpanded = false;

  void _handleConsult(BuildContext context, AppState appState) {
    final astro = appState.astrologers.firstWhere(
      (a) => a.id == widget.astrologer.id,
      orElse: () => widget.astrologer,
    );

    if (!astro.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${astro.displayName} is currently offline.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (appState.walletBalance < astro.ratePerMinute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum balance of ₹${astro.ratePerMinute.toStringAsFixed(0)} required to start consultation.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    appState.startConsultation(astro.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConsultationScreen(astrologer: astro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final astro = appState.astrologers.firstWhere(
      (a) => a.id == widget.astrologer.id,
      orElse: () => widget.astrologer,
    );
    final bioText = astro.bio.isNotEmpty
        ? astro.bio
        : '${astro.specialties.join(", ")} expert with ${astro.experienceYears}+ years experience in Vedic consultations, kundli chart analysis, and life guidance.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Bigger Avatar on Left + Name & Smaller Tags on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bigger Image Avatar (Radius 44, Diameter 88)
              Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.cardPurple.withAlpha(35),
                    backgroundImage: astro.avatarUrl.isNotEmpty
                        ? NetworkImage(astro.avatarUrl)
                        : null,
                    child: astro.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 44, color: AppTheme.cardLilac)
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: astro.isOnline ? AppTheme.accentCyan : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceDark, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name & Smaller Tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        Text(
                          astro.displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textWhite,
                            letterSpacing: -0.2,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Smaller Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (astro.specialties.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cardPurple.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              astro.specialties.first,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPurpleLight,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceTile,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderSubtle, width: 0.8),
                          ),
                          child: Text(
                            astro.isOnline
                                ? 'Gold Verified'
                                : '${astro.experienceYears}+ Yrs',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.cardCoral,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceTile,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderSubtle, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 11),
                              const SizedBox(width: 3),
                              Text(
                                astro.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Languages
                    Wrap(
                      children: [
                        Text(
                          astro.languages.join(", "),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textMuted,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Expandable Description
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(
                      bioText,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isExpanded ? 'Show less' : 'Read more',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cardLilac,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bottom Action Row: Black Pill Button + 2 Circular Outline Buttons
          Row(
            children: [
              // + Consult Pill Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _handleConsult(context, appState),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: astro.isOnline ? AppTheme.cardPurple : AppTheme.surfaceTile,
                      borderRadius: BorderRadius.circular(23),
                      border: astro.isOnline ? null : Border.all(color: AppTheme.borderSubtle),
                      boxShadow: astro.isOnline
                          ? [
                              BoxShadow(
                                color: AppTheme.cardPurple.withAlpha(50),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          astro.isOnline ? Icons.add : Icons.do_not_disturb_on_outlined,
                          color: astro.isOnline ? Colors.white : AppTheme.textMuted,
                          size: 17,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            astro.isOnline
                                ? 'Consult (₹${astro.ratePerMinute.toStringAsFixed(0)}/min)'
                                : 'Offline (₹${astro.ratePerMinute.toStringAsFixed(0)}/min)',
                            style: TextStyle(
                              color: astro.isOnline ? Colors.white : AppTheme.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Circular Outline Button 1: Chat
              GestureDetector(
                onTap: () => _handleConsult(context, appState),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceTile,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Circular Outline Button 2: Notification / Alerts
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Subscribed to ${astro.displayName}\'s schedule.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceTile,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
