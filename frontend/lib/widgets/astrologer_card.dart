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
    if (appState.walletBalance < widget.astrologer.ratePerMinute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum balance of ₹${widget.astrologer.ratePerMinute.toStringAsFixed(0)} required to start consultation.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    appState.startConsultation(widget.astrologer.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConsultationScreen(astrologer: widget.astrologer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final astro = widget.astrologer;
    final bioText = astro.bio.isNotEmpty
        ? astro.bio
        : '${astro.specialties.join(", ")} expert with ${astro.experienceYears}+ years experience in Vedic consultations, kundli matching, and remedies.';

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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Big Avatar + Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bigger Image Avatar (diameter 84) with Online Status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppTheme.cardPurple.withAlpha(35),
                    backgroundImage: astro.avatarUrl.isNotEmpty
                        ? NetworkImage(astro.avatarUrl)
                        : null,
                    child: astro.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 40, color: AppTheme.cardLilac)
                        : null,
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: astro.isOnline ? AppTheme.accentCyan : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceDark, width: 2.2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name, Smaller Tags, Experience
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppTheme.cardPurple.withAlpha(35),
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
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceTile,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.borderSubtle, width: 0.8),
                          ),
                          child: Text(
                            '${astro.experienceYears}+ Yrs',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
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

          // Bottom Action Row: Rate + Consult Pill Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${astro.ratePerMinute.toStringAsFixed(0)} / min',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textWhite,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardPurple,
                  foregroundColor: AppTheme.textWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _handleConsult(context, appState),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.chat_bubble_outline, size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Consult',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
