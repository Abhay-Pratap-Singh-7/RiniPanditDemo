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
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceTile,
            borderRadius: AppTheme.tileRadius,
            border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF212856),
                Color(0xFF15193E),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Asset Icon with graceful fallback
              SizedBox(
                height: 48,
                width: 48,
                child: Image.asset(
                  'assets/icons/$assetName',
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardPurple.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(fallbackIcon, color: AppTheme.cardLilac, size: 26),
                    );
                  },
                ),
              ),

              // Title with soft wrapping
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
