import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../screens/wallet_screen.dart';
import '../screens/auth_screen.dart';
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
    final appState = context.watch<AppState>();
    final canPop = Navigator.canPop(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: canPop
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textWhite,
                size: 19,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Row(
        children: [
          if (!canPop) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cardPurple.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.nightlight_round, color: AppTheme.cardLilac, size: 20),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Supabase Auth / Profile Button
        IconButton(
          icon: Icon(
            appState.isAuthenticated ? Icons.account_circle : Icons.account_circle_outlined,
            color: appState.isAuthenticated ? AppTheme.accentCyan : AppTheme.cardLilac,
            size: 22,
          ),
          tooltip: appState.isAuthenticated ? 'Account Profile' : 'Sign In with Supabase',
          onPressed: () {
            if (appState.isAuthenticated) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            }
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
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceTile,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 15,
                    color: AppTheme.cardCoral,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '₹${appState.walletBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
