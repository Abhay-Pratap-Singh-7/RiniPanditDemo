import 'package:flutter/material.dart';

class CosmicScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const CosmicScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBody = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Universal Deep Cosmic Starry Wallpaper (Fills 100% of entire physical screen)
        Positioned.fill(
          child: Image.asset(
            'assets/bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0B0E23),
            ),
          ),
        ),
        // Subtle deep tint overlay for maximum readability
        Positioned.fill(
          child: Container(
            color: const Color(0x38080B1E),
          ),
        ),
        // Scaffold with transparent canvas extending behind BottomNav
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: extendBody,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: appBar,
          body: SafeArea(
            top: appBar == null,
            bottom: false,
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}
