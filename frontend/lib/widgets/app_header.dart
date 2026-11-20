import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../screens/wallet_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/role_selection_screen.dart';

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
    final appState = context.watch<AppState>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.cardPurple.withAlpha(50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.nightlight_round, color: AppTheme.cardLilac, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Role Switcher Button
        IconButton(
          icon: const Icon(Icons.swap_horiz, color: AppTheme.cardLilac, size: 22),
          tooltip: 'Switch Role (Client / Pandit)',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
            );
          },
        ),

        if (showBalance)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceTile,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.cardLilac, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    '₹${appState.walletBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.add, color: AppTheme.cardCoral, size: 15),
                ],
              ),
            ),
          ),

        IconButton(
          icon: CircleAvatar(
            radius: 17,
            backgroundColor: AppTheme.cardPurple,
            backgroundImage: appState.userProfile?.avatarUrl.isNotEmpty == true
                ? NetworkImage(appState.userProfile!.avatarUrl)
                : null,
            child: appState.userProfile?.avatarUrl.isEmpty != false
                ? const Icon(Icons.person, size: 18, color: AppTheme.textWhite)
                : null,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}
