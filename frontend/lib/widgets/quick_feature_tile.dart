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
          height: 96, // Reduced compact height
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceTile,
            borderRadius: AppTheme.tileRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(70),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Asset taking full card size
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 20, left: 6, right: 6),
                child: Image.asset(
                  'assets/icons/$assetName',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(fallbackIcon, color: AppTheme.cardLilac, size: 30),
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
                        Color(0x220B0E23),
                        Color(0xD90B0E23),
                        Color(0xF50B0E23),
                      ],
                      stops: [0.0, 0.40, 0.72, 1.0],
                    ),
                  ),
                ),
              ),

              // Title written on top of the vertical overlay
              Positioned(
                left: 4,
                right: 4,
                bottom: 6,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.15,
                        ),
                        maxLines: 2,
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
                      borderRadius: AppTheme.tileRadius,
                      border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
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
