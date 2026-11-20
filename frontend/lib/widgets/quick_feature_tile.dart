import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class QuickFeatureTile extends StatelessWidget {
  final String title;
  final String assetName;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const QuickFeatureTile({
    super.key,
    required this.title,
    required this.assetName,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 74, // Ultra-compact sleek height
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceTile,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Asset taking full card size
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16, left: 4, right: 4),
                child: Image.asset(
                  'assets/icons/$assetName',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(fallbackIcon, color: AppTheme.cardLilac, size: 24),
                    );
                  },
                ),
              ),

              // Transparent-to-dark vertical overlay
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x330B0E23),
                        Color(0xE60B0E23),
                        Color(0xF80B0E23),
                      ],
                      stops: [0.0, 0.35, 0.70, 1.0],
                    ),
                  ),
                ),
              ),

              // Title written on top of the vertical overlay
              Positioned(
                left: 3,
                right: 3,
                bottom: 4,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 9.8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
