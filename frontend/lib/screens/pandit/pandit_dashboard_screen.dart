import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/cosmic_scaffold.dart';
import '../profile_screen.dart';
import 'pandit_chat_screen.dart';
import 'pandit_earnings_screen.dart';
import 'pandit_profile_setup_screen.dart';

class PanditDashboardScreen extends StatefulWidget {
  const PanditDashboardScreen({super.key});

  @override
  State<PanditDashboardScreen> createState() => _PanditDashboardScreenState();
}

class _PanditDashboardScreenState extends State<PanditDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final appState = context.read<AppState>();
      await appState.loadPanditData();
      if (!mounted) return;
      _checkProfileIncomplete(appState);
    });
  }

  void _checkProfileIncomplete(AppState appState) {
    final pandit = appState.currentPandit;
    if (pandit == null || pandit.bio.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppTheme.borderSubtle, width: 1.2),
          ),
          title: Row(
            children: const [
              Icon(Icons.assignment_late_outlined, color: AppTheme.cardCoral, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your astrologer profile is not configured yet. Please set your consultation rate, specialties, and bio to start receiving consultations.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
            softWrap: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cardPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PanditProfileSetupScreen()),
                );
              },
              child: const Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pandit = appState.currentPandit;
    final earnings = appState.panditEarnings;
    final incoming = appState.incomingRequest;
    final activeSession = appState.activeSession;

    final displayName = pandit?.displayName.isNotEmpty == true
        ? pandit!.displayName
        : (appState.userProfile?.fullName.isNotEmpty == true
            ? appState.userProfile!.fullName
            : 'Acharya');

    final specialtiesText = pandit?.specialties.isNotEmpty == true
        ? pandit!.specialties.join(', ')
        : 'Vedic, Kundli';

    final expYears = pandit?.experienceYears ?? 5;
    final ratePerMin = pandit?.ratePerMinute ?? 25.0;

    final totalEarned = (earnings['totalEarned'] as num?)?.toDouble() ?? 0.0;
    final totalMinutes = (earnings['totalMinutes'] as num?)?.toInt() ?? 0;
    final completedSessions = (earnings['completedSessions'] as num?)?.toInt() ?? appState.panditSessions.length;

    return CosmicScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.cardLilac.withAlpha(80), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  'assets/logo.webp',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pandit Portal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: (pandit?.isOnline ?? true)
                  ? AppTheme.accentCyan.withAlpha(25)
                  : AppTheme.textMuted.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (pandit?.isOnline ?? true)
                    ? AppTheme.accentCyan.withAlpha(80)
                    : AppTheme.textMuted.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: (pandit?.isOnline ?? true) ? AppTheme.accentCyan : AppTheme.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  (pandit?.isOnline ?? true) ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: (pandit?.isOnline ?? true) ? AppTheme.accentCyan : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppTheme.cardLilac, size: 23),
            tooltip: 'Account Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await appState.loadPanditData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Incomplete Profile Alert Banner
              if (pandit == null || pandit.bio.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardCoral.withAlpha(25),
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.cardCoral.withAlpha(90), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.cardCoral, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Profile Setup Incomplete',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textWhite,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Set your rate and specialties to start receiving consultations.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cardCoral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PanditProfileSetupScreen()),
                          );
                        },
                        child: const Text('Setup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                      radius: 32,
                      backgroundColor: AppTheme.cardPurple.withAlpha(50),
                      backgroundImage: pandit?.avatarUrl.isNotEmpty == true
                          ? NetworkImage(pandit!.avatarUrl)
                          : null,
                      child: pandit?.avatarUrl.isEmpty != false
                          ? const Icon(Icons.person, size: 34, color: AppTheme.cardLilac)
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
                                displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$specialtiesText • $expYears yrs exp',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            pandit?.isOnline == true ? 'Accepting Consultations' : 'Currently Offline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: pandit?.isOnline == true ? AppTheme.accentCyan : AppTheme.textMuted,
                            ),
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
                          Expanded(
                            child: Text(
                              'Incoming Live Consultation',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Client: ${incoming["user"]?["full_name"] ?? incoming["user"]?["phone"] ?? "Devotee"}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        softWrap: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rate: ₹${incoming["session"]?["rate_per_minute"] ?? ratePerMin.toStringAsFixed(0)}/min • Type: Live Chat',
                        style: const TextStyle(color: Color(0xEEFFFFFF), fontSize: 12),
                        softWrap: true,
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
                              onPressed: () {
                                appState.acceptIncomingRequest();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PanditChatScreen()),
                                );
                              },
                              child: const Text('Accept & Join'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white70),
                            ),
                            onPressed: () {
                              appState.declineIncomingRequest();
                            },
                            child: const Text('Decline', style: TextStyle(color: Colors.white)),
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
                              'Active Session in Progress',
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

              // Overview & Metrics Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overview & Performance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PanditEarningsScreen()),
                      );
                    },
                    child: const Text('View All', style: TextStyle(color: AppTheme.cardLilac, fontSize: 13)),
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
                    value: '₹${totalEarned.toStringAsFixed(0)}',
                    color: AppTheme.accentCyan,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  _buildStatBadge(
                    title: 'Minutes Consulted',
                    value: '$totalMinutes mins',
                    color: AppTheme.cardLilac,
                    icon: Icons.timer_outlined,
                  ),
                  _buildStatBadge(
                    title: 'Completed Sessions',
                    value: '$completedSessions',
                    color: AppTheme.cardCoral,
                    icon: Icons.task_alt,
                  ),
                  _buildStatBadge(
                    title: 'Consultation Rate',
                    value: '₹${ratePerMin.toStringAsFixed(0)} / min',
                    color: Colors.amberAccent,
                    icon: Icons.price_change_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Consultations
              const Text(
                'Recent Client Consultations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                        child: Text(
                          'No past consultations recorded yet.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
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
                                '+₹${s.totalDeducted.toStringAsFixed(0)}',
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
      padding: const EdgeInsets.all(12),
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
              Icon(icon, size: 15, color: color),
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
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
