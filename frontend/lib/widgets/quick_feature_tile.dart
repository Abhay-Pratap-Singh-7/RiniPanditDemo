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
          height: 125,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceTile,
            borderRadius: AppTheme.tileRadius,
            border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Asset taking full card size
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 24, left: 10, right: 10),
                child: Image.asset(
                  'assets/icons/$assetName',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(fallbackIcon, color: AppTheme.cardLilac, size: 38),
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
                        Color(0xD90B0E23),
                        Color(0xF50B0E23),
                      ],
                      stops: [0.0, 0.45, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // Title written on top of the vertical overlay
              Positioned(
                left: 6,
                right: 6,
                bottom: 8,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
