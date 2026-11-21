import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
import '../widgets/app_header.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _filter = 'all';

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
    final canPop = Navigator.canPop(context);

    final filteredTransactions = appState.transactions.where((tx) {
      if (_filter == 'all') return true;
      if (_filter == 'recharge') return tx.type == 'recharge' || tx.type == 'promo_credit';
      if (_filter == 'consultation') return tx.type == 'consultation';
      return true;
    }).toList();

    final content = Column(
      children: [
        const AppHeader(
          title: 'Astro Wallet',
          showBalance: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, canPop ? 30 : 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Available Balance Card
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
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentCyan,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Available Balance',
                                  style: TextStyle(
                                    color: Color(0xEEFFFFFF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '₹${appState.walletBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              children: const [
                                Text(
                                  'Auto-deducted per minute during live consultations and Kundli guidance.',
                                  style: TextStyle(color: Color(0xDDFFFFFF), fontSize: 12),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: Image.asset(
                          'assets/icons/tile_wallet.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Top-up Section Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppTheme.cardPurple.withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_card_rounded, color: AppTheme.cardLilac, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Add Money to Wallet',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppTheme.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Custom Amount Input
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(
                            color: AppTheme.cardLilac,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          labelText: 'Enter Amount',
                          hintText: 'e.g. 500',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                          filled: true,
                          fillColor: AppTheme.surfaceTile,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Recharge Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cardPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: appState.isLoading
                              ? null
                              : () async {
                                  final amount = double.tryParse(_amountController.text);
                                  if (amount == null || amount <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid amount to recharge.'),
                                      ),
                                    );
                                    return;
                                  }
                                  await appState.rechargeWallet(amount);
                                  if (!context.mounted) return;
                                  _amountController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Recharge of ₹${amount.toStringAsFixed(0)} completed successfully.'),
                                      backgroundColor: AppTheme.cardPurple,
                                    ),
                                  );
                                },
                          child: appState.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 20, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _amountController.text.isNotEmpty
                                            ? 'Add ₹${_amountController.text} to Wallet'
                                            : 'Add Money to Wallet',
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_outline_rounded, size: 14, color: AppTheme.textMuted),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '100% Secure & Encrypted Payments via UPI, Cards & NetBanking',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction History Header & Filter Chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction History',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppTheme.textWhite,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '${filteredTransactions.length} records',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Recharge', 'recharge'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Consultations', 'consultation'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Transaction List
                if (filteredTransactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.receipt_long_outlined, size: 40, color: AppTheme.textMuted),
                        SizedBox(height: 8),
                        Text(
                          'No transactions in this category yet',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      final isCredit = tx.type == 'recharge' || tx.type == 'promo_credit';
                      final dateDisplay = tx.createdAt.contains('T')
                          ? tx.createdAt.split('T')[0]
                          : (tx.createdAt.length > 10 ? tx.createdAt.substring(0, 10) : tx.createdAt);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderSubtle, width: 1),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 19,
                              backgroundColor: isCredit
                                  ? AppTheme.accentCyan.withAlpha(25)
                                  : AppTheme.cardCoral.withAlpha(25),
                              child: Icon(
                                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                size: 18,
                                color: isCredit ? AppTheme.accentCyan : AppTheme.cardCoral,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.description,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dateDisplay,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isCredit ? "+" : "-"}₹${tx.amount.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isCredit ? AppTheme.accentCyan : AppTheme.cardCoral,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceTile,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    if (canPop) {
      return CosmicScaffold(
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardPurple : AppTheme.surfaceTile,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.cardLilac : AppTheme.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
