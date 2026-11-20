import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.5, -0.3),
              end: const Alignment(1.5, 0.3),
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              colors: [
                AppTheme.surfaceTile,
                AppTheme.surfaceTile,
                AppTheme.cardPurple.withAlpha(90),
                AppTheme.surfaceTile,
                AppTheme.surfaceTile,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: AppTheme.surfaceTile,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
      ),
    );
  }
}

class AstrologerCardShimmer extends StatelessWidget {
  const AstrologerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(
                  width: 88,
                  height: 88,
                  shape: CircleBorder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerPlaceholder(width: 140, height: 18),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          ShimmerPlaceholder(width: 55, height: 16),
                          SizedBox(width: 6),
                          ShimmerPlaceholder(width: 65, height: 16),
                          SizedBox(width: 6),
                          ShimmerPlaceholder(width: 40, height: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const ShimmerPlaceholder(width: 100, height: 13),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const ShimmerPlaceholder(width: double.infinity, height: 13),
            const SizedBox(height: 6),
            const ShimmerPlaceholder(width: 220, height: 13),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  child: ShimmerPlaceholder(
                    width: double.infinity,
                    height: 46,
                    borderRadius: BorderRadius.all(Radius.circular(23)),
                  ),
                ),
                SizedBox(width: 10),
                ShimmerPlaceholder(width: 46, height: 46, shape: CircleBorder()),
                SizedBox(width: 8),
                ShimmerPlaceholder(width: 46, height: 46, shape: CircleBorder()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
