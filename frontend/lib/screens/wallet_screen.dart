import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController(text: '500');
  final List<double> _presets = [100, 250, 500, 1000];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return CosmicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Astro Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Balance Card with Sunset / Coral Gradient and Wallet Illustration
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.cardPurple,
                    AppTheme.cardCoral,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppTheme.cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cardPurple.withAlpha(70),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: Color(0xEEFFFFFF), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${appState.walletBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          children: const [
                            Text(
                              'Instant per-minute recharge for consultations and Kundli readings.',
                              style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 75,
                    height: 75,
                    child: Image.asset(
                      'assets/icons/tile_wallet.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.account_balance_wallet,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top-up Section
            const Text(
              'Select Amount to Add',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Presets
            Row(
              children: _presets.map((preset) {
                final isSelected = _amountController.text == preset.toStringAsFixed(0);
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? AppTheme.cardPurple : AppTheme.surfaceTile,
                        side: BorderSide(
                          color: isSelected ? AppTheme.cardPurple : AppTheme.borderSubtle,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          _amountController.text = preset.toStringAsFixed(0);
                        });
                      },
                      child: Text(
                        '₹${preset.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppTheme.cardLilac, fontSize: 18, fontWeight: FontWeight.bold),
                labelText: 'Enter Custom Amount',
              ),
            ),
            const SizedBox(height: 16),

            // Recharge Button
            ElevatedButton(
              onPressed: appState.isLoading
                  ? null
                  : () async {
                      final amount = double.tryParse(_amountController.text);
                      if (amount != null && amount > 0) {
                        await appState.rechargeWallet(amount);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recharge of ₹${amount.toStringAsFixed(0)} completed successfully.'),
                            backgroundColor: AppTheme.cardPurple,
                          ),
                        );
                      }
                    },
              child: appState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Add Money to Wallet'),
            ),
            const SizedBox(height: 30),

            // Transaction History
            const Text(
              'Transaction History',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            appState.transactions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withAlpha(200),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Center(
                      child: Text('No transactions recorded yet', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.transactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = appState.transactions[index];
                      final isCredit = tx.type == 'recharge' || tx.type == 'promo_credit';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withAlpha(210),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: isCredit
                                  ? AppTheme.accentCyan.withAlpha(30)
                                  : Colors.redAccent.withAlpha(30),
                              child: Icon(
                                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isCredit ? AppTheme.accentCyan : Colors.redAccent,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    children: [
                                      Text(
                                        tx.description,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Balance: ₹${tx.balanceAfter.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? '+' : ''}₹${tx.amount.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isCredit ? AppTheme.accentCyan : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
