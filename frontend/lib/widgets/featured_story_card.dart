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
        height: 116,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppTheme.cardRadius,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withAlpha(70),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full card image asset placed UNDER the text
            Positioned(
              right: -10,
              top: -10,
              bottom: -10,
              width: 210,
              child: Opacity(
                opacity: 0.92,
                child: Image.asset(
                  'assets/cards/$assetName',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(fallbackIcon, size: 50, color: Colors.white.withAlpha(220)),
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
                      backgroundColor.withAlpha(250),
                      backgroundColor.withAlpha(220),
                      backgroundColor.withAlpha(120),
                      backgroundColor.withAlpha(30),
                    ],
                    stops: const [0.0, 0.45, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Text on top across full width
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
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
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
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
                            color: Color(0xEEFFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
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
                    border: Border.all(color: Colors.white.withAlpha(40), width: 1.2),
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
