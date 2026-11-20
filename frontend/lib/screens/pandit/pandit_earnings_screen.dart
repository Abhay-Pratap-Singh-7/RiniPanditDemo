import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/cosmic_scaffold.dart';

class PanditEarningsScreen extends StatelessWidget {
  const PanditEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final earnings = appState.panditEarnings;
    final sessions = appState.panditSessions;

    return CosmicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Earnings & Settlements'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Earnings Card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Net Accumulated Earnings',
                    style: TextStyle(color: Color(0xEEFFFFFF), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${earnings["totalEarned"] ?? "350.00"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: const [
                      Text(
                        'Direct payout processed weekly to your verified bank account.',
                        style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
                        softWrap: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Performance Summary
            const Text(
              'Performance Summary',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withAlpha(220),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Total Consulted Minutes', '${earnings["totalMinutes"] ?? "10"} mins'),
                  const Divider(color: Color(0x22FFFFFF), height: 20),
                  _buildSummaryRow('Completed Sessions', '${earnings["completedSessions"] ?? "3"}'),
                  const Divider(color: Color(0x22FFFFFF), height: 20),
                  _buildSummaryRow('Consultation Rate', '₹${appState.currentPandit?.ratePerMinute.toStringAsFixed(0) ?? "35"} / min'),
                  const Divider(color: Color(0x22FFFFFF), height: 20),
                  _buildSummaryRow('Platform Commission', '10% (Introductory Rate)'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Session Ledger
            const Text(
              'Session Ledger',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            sessions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withAlpha(200),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Center(
                      child: Text('No completed sessions found', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = sessions[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withAlpha(210),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Live ${s.type.toUpperCase()} Consultation',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Status: ${s.status} • Duration: ${s.durationSeconds ~/ 60} mins',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            Text(
                              '+₹${s.totalDeducted.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentCyan,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
      ],
    );
  }
}
