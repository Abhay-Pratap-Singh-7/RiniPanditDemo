import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/astrologer.dart';
import '../providers/app_state.dart';
import '../screens/chat_consultation_screen.dart';

class AstrologerCard extends StatelessWidget {
  final Astrologer astrologer;

  const AstrologerCard({super.key, required this.astrologer});

  void _handleConsult(BuildContext context, AppState appState) {
    if (appState.walletBalance < astrologer.ratePerMinute) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum balance of ₹${astrologer.ratePerMinute.toStringAsFixed(0)} required to start consultation.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
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
  }

  void _showAstrologerDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFEBF1FA),
                  backgroundImage: astrologer.avatarUrl.isNotEmpty
                      ? NetworkImage(astrologer.avatarUrl)
                      : null,
                  child: astrologer.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 28, color: Color(0xFF4D638B))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        astrologer.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2022),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${astrologer.experienceYears}+ years experience • ${astrologer.languages.join(", ")}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: astrologer.specialties.map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF1FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s,
                    style: const TextStyle(
                      color: Color(0xFF4D638B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text(
              astrologer.bio.isNotEmpty
                  ? astrologer.bio
                  : 'Certified astrologer providing accurate Vedic astrological readings, horoscope matching, and remedies.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate: ₹${astrologer.ratePerMinute.toStringAsFixed(0)} / min',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2022),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${astrologer.rating.toStringAsFixed(1)} (${astrologer.totalReviews} reviews)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E2022),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outer Aurora Gradient Frame
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFAEC4DE), // Soft periwinkle/blue
                  Color(0xFFECA37F), // Sunset apricot / peach
                  Color(0xFFDF7E66), // Coral
                  Color(0xFFC0A3BE), // Dusty rose / lavender
                ],
                stops: [0.0, 0.38, 0.68, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 48, 10, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Avatar Spacer & Astrologer Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 82), // Room for overlapping avatar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: [
                                  Text(
                                    astrologer.displayName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E2022),
                                      letterSpacing: -0.2,
                                    ),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEBF1FA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      astrologer.specialties.isNotEmpty
                                          ? astrologer.specialties.first
                                          : 'Vedic',
                                      style: const TextStyle(
                                        color: Color(0xFF4D638B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFBF0DC),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      astrologer.isOnline
                                          ? 'Gold Verified'
                                          : '${astrologer.experienceYears}+ Yrs Exp',
                                      style: const TextStyle(
                                        color: Color(0xFFA67123),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Bio / Tagline with Wrap
                    Wrap(
                      children: [
                        Text(
                          astrologer.bio.isNotEmpty
                              ? astrologer.bio
                              : '${astrologer.specialties.join(", ")} expert with ${astrologer.experienceYears}+ years experience in Vedic consultations and predictions.',
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: Color(0xFF5A6475),
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Row: Pill Button + 2 Circular Outline Buttons
                    Row(
                      children: [
                        // Black Pill Button (+ Consult)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _handleConsult(context, appState),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111215),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add, color: Colors.white, size: 18),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Consult (₹${astrologer.ratePerMinute.toStringAsFixed(0)}/min)',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
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

                        // Circular Button 1: Chat Outline
                        GestureDetector(
                          onTap: () => _handleConsult(context, appState),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE2E5EB),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 19,
                                color: Color(0xFF1E2022),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Circular Button 2: Notification / Star Details Outline
                        GestureDetector(
                          onTap: () => _showAstrologerDetails(context),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE2E5EB),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 21,
                                color: Color(0xFF1E2022),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overlapping Avatar with White Rim
          Positioned(
            top: 14,
            left: 24,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: astrologer.avatarUrl.isNotEmpty
                    ? Image.network(
                        astrologer.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFEBF1FA),
                            child: const Icon(
                              Icons.person,
                              size: 36,
                              color: Color(0xFF4D638B),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFFEBF1FA),
                        child: const Icon(
                          Icons.person,
                          size: 36,
                          color: Color(0xFF4D638B),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
