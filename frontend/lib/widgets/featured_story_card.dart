import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class FeaturedStoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final String assetName;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const FeaturedStoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.accentColor = AppTheme.cardPurple,
    required this.assetName,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 142,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withAlpha(235), // App background surface color
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full card image asset placed UNDER the text
            Positioned(
              right: -5,
              top: -10,
              bottom: -10,
              width: 195,
              child: Opacity(
                opacity: 0.90,
                child: Image.asset(
                  'assets/cards/$assetName',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(fallbackIcon, size: 44, color: accentColor),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Horizontal gradient overlay for high text contrast across full width
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.surfaceDark,
                      AppTheme.surfaceDark.withAlpha(230),
                      AppTheme.surfaceDark.withAlpha(120),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.70, 1.0],
                  ),
                ),
              ),
            ),

            // Text on top across full width
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.62,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      children: [
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Top Border Layer: ensures overlays never bleed over the border
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
