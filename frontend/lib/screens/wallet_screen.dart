import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

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
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Astro Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Balance Golden Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withAlpha(220),
                    theme.colorScheme.secondary.withAlpha(200),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(50),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${appState.walletBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use balance for Live Vedic consultations, Tarot sessions, and Kundli remedies.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Top-up Section
            Text(
              'Add Money to Wallet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
                        backgroundColor: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                        side: BorderSide(
                          color: isSelected ? theme.colorScheme.primary : const Color(0x33FFB300),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                          color: isSelected ? Colors.black : Colors.white,
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
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: theme.colorScheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
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
                            content: Text('Recharge of ₹${amount.toStringAsFixed(0)} successful!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
              child: appState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Proceed to Add Money (Demo Instant)'),
            ),
            const SizedBox(height: 30),

            // Transaction History
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            appState.transactions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No transactions yet', style: TextStyle(color: Colors.white60)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.transactions.length,
                    separatorBuilder: (_, _) => const Divider(color: Color(0x22FFFFFF)),
                    itemBuilder: (context, index) {
                      final tx = appState.transactions[index];
                      final isCredit = tx.type == 'recharge' || tx.type == 'promo_credit';

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isCredit
                              ? Colors.greenAccent.withAlpha(40)
                              : Colors.redAccent.withAlpha(40),
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isCredit ? Colors.greenAccent : Colors.redAccent,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          tx.description,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Balance: ₹${tx.balanceAfter.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        trailing: Text(
                          '${isCredit ? '+' : ''}₹${tx.amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isCredit ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
