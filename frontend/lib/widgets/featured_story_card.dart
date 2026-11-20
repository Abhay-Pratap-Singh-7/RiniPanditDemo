import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class FeaturedStoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String assetName;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const FeaturedStoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.assetName,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppTheme.cardRadius,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left content (Title & Subtitle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.52,
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
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: [
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 12,
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

            // Right Artwork / Asset with fallback
            Positioned(
              right: 12,
              bottom: 0,
              top: 0,
              child: SizedBox(
                width: 130,
                child: Image.asset(
                  'assets/cards/$assetName',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(fallbackIcon, size: 48, color: Colors.white.withAlpha(220)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
