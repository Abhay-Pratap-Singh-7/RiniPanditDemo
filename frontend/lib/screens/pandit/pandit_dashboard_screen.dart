import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/cosmic_scaffold.dart';
import '../role_selection_screen.dart';
import 'pandit_chat_screen.dart';
import 'pandit_earnings_screen.dart';

class PanditDashboardScreen extends StatelessWidget {
  const PanditDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pandit = appState.currentPandit;
    final earnings = appState.panditEarnings;
    final incoming = appState.incomingRequest;
    final activeSession = appState.activeSession;

    return CosmicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cardPurple.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.psychology_outlined, color: AppTheme.cardLilac, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Pandit Portal'),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz, color: AppTheme.cardLilac, size: 18),
            label: const Text('Switch Role', style: TextStyle(color: AppTheme.cardLilac, fontSize: 13)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pandit Profile & Online Switch Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withAlpha(220),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppTheme.cardPurple.withAlpha(50),
                    backgroundImage: pandit?.avatarUrl.isNotEmpty == true
                        ? NetworkImage(pandit!.avatarUrl)
                        : null,
                    child: pandit?.avatarUrl.isEmpty != false
                        ? const Icon(Icons.person, size: 36, color: AppTheme.cardLilac)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          children: [
                            Text(
                              pandit?.displayName ?? 'Acharya Rini Pandit',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              softWrap: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pandit?.specialties.take(2).join(", ") ?? "Vedic, Kundli"} • ${pandit?.experienceYears ?? 25}+ yrs',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              pandit?.isOnline == true ? 'Online for Consultations' : 'Offline',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pandit?.isOnline == true ? AppTheme.accentCyan : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: pandit?.isOnline ?? true,
                    activeThumbColor: AppTheme.accentCyan,
                    onChanged: (val) {
                      appState.togglePanditOnline(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Incoming Consultation Request Alert (Real-time WebSocket event)
            if (incoming != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B2500), Color(0xFFE65100)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppTheme.cardRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withAlpha(90),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.ring_volume, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Incoming Live Consultation!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Client: ${incoming["user"]?["full_name"] ?? "Rahul Sharma"} (${incoming["user"]?["phone"] ?? ""})',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rate: ₹${incoming["session"]?["rate_per_minute"] ?? "35"}/min • Type: Live Chat',
                      style: const TextStyle(color: Color(0xEEFFFFFF), fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Accept & Join'),
                            onPressed: () {
                              appState.acceptIncomingRequest();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PanditChatScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70),
                          ),
                          child: const Text('Decline', style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            appState.declineIncomingRequest();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Active Consultation Quick Banner
            if (activeSession != null) ...[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PanditChatScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardPurple,
                    borderRadius: AppTheme.cardRadius,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.chat_bubble_outline, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Active Client Session in Progress',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Earnings & Metrics Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overview & Performance',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PanditEarningsScreen()),
                    );
                  },
                  child: const Text('View All', style: TextStyle(color: AppTheme.cardLilac)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 4 Stats Badges
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _buildStatBadge(
                  title: 'Total Earnings',
                  value: '₹${earnings["totalEarned"] ?? "350"}',
                  color: AppTheme.accentCyan,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                _buildStatBadge(
                  title: 'Minutes Consulted',
                  value: '${earnings["totalMinutes"] ?? "10"} mins',
                  color: AppTheme.cardLilac,
                  icon: Icons.timer_outlined,
                ),
                _buildStatBadge(
                  title: 'Completed Sessions',
                  value: '${earnings["completedSessions"] ?? "3"}',
                  color: AppTheme.cardCoral,
                  icon: Icons.task_alt,
                ),
                _buildStatBadge(
                  title: 'My Rate / Min',
                  value: '₹${pandit?.ratePerMinute.toStringAsFixed(0) ?? "35"}',
                  color: Colors.amberAccent,
                  icon: Icons.price_change_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Consultations
            const Text(
              'Recent Client Consultations',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            appState.panditSessions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withAlpha(200),
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: const Center(
                      child: Text('No past sessions recorded yet', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.panditSessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = appState.panditSessions[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withAlpha(220),
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
                                  'Session: ${s.type.toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: ${s.durationSeconds ~/ 60} mins (${s.status})',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            Text(
                              '+₹${s.totalDeducted.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withAlpha(220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
