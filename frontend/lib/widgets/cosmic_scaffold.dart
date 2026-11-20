import 'package:flutter/material.dart';

class CosmicScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const CosmicScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: Stack(
        children: [
          // Universal Deep Starry Cosmic Background
          Positioned.fill(
            child: Image.asset(
              'assets/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Subtle tint overlay to guarantee clean text contrast
          Positioned.fill(
            child: Container(
              color: const Color(0x44080B1E),
            ),
          ),
          // Foreground Screen Body
          SafeArea(
            bottom: false,
            child: body,
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
