import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../screens/wallet_screen.dart';
import '../screens/profile_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBalance;

  const AppHeader({
    super.key,
    required this.title,
    this.showBalance = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 8),
          Text(title, style: theme.appBarTheme.titleTextStyle),
        ],
      ),
      actions: [
        if (showBalance)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '₹${appState.walletBalance.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.add_circle, color: Colors.greenAccent, size: 16),
                ],
              ),
            ),
          ),
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            backgroundImage: appState.userProfile?.avatarUrl.isNotEmpty == true
                ? NetworkImage(appState.userProfile!.avatarUrl)
                : null,
            child: appState.userProfile?.avatarUrl.isEmpty != false
                ? const Icon(Icons.person, size: 18, color: Colors.black)
                : null,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
