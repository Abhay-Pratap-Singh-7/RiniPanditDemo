import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/cosmic_scaffold.dart';

class PanditChatScreen extends StatefulWidget {
  const PanditChatScreen({super.key});

  @override
  State<PanditChatScreen> createState() => _PanditChatScreenState();
}

class _PanditChatScreenState extends State<PanditChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final session = appState.activeSession;
    final client = appState.activeConsultationUser;
    final messages = appState.messages;

    _scrollToBottom();

    return CosmicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.cardCoral.withAlpha(50),
              child: const Icon(Icons.person, size: 20, color: AppTheme.cardCoral),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      Text(
                        client?.fullName ?? 'Devotee / Client',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        softWrap: true,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Connection Established • ₹${session?.ratePerMinute.toStringAsFixed(0) ?? "25"}/min',
                          style: const TextStyle(fontSize: 11, color: AppTheme.cardLilac),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceTile,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: appState.isTimerRunning ? AppTheme.accentCyan.withAlpha(120) : AppTheme.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: appState.isTimerRunning ? AppTheme.accentCyan : AppTheme.cardLilac,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(appState.activeSessionElapsedSeconds),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: appState.isTimerRunning ? AppTheme.accentCyan : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // End Session Button
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.redAccent),
            tooltip: 'End Session',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surfaceDark,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
                  title: const Text('End Consultation', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Are you sure you want to end this client session?',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.cardLilac)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('End Consultation', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        appState.endActiveConsultation();
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Client Chart & Live Earnings Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceTile.withAlpha(220),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DOB: ${client?.dob ?? "1995-08-15"} | ${client?.tob ?? "07:30"}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Place: ${client?.pobCity ?? "New Delhi"}, ${client?.pobCountry ?? "India"}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.cardLilac),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardPurple.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.cardLilac.withAlpha(80)),
                  ),
                  child: Text(
                    'Earned: ₹${appState.activeConsultationEarned.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withAlpha(25),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.accentCyan, width: 2),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.accentCyan,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Connection Established',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Connected with ${client?.fullName ?? "Devotee / Client"}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.cardLilac,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Text(
                              'Rate: ₹${session?.ratePerMinute.toStringAsFixed(0) ?? "25"}/min • Timer starts when client sends first message',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Client session active. Type your guidance below.',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      // In Pandit screen, sender is pandit if senderId == currentPandit.id
                      final isPanditSender = msg.senderId == appState.currentPandit?.id;

                      return Align(
                        alignment: isPanditSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isPanditSender
                                ? AppTheme.cardPurple
                                : AppTheme.surfaceDark.withAlpha(230),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isPanditSender ? const Radius.circular(20) : Radius.zero,
                              bottomRight: isPanditSender ? Radius.zero : const Radius.circular(20),
                            ),
                            border: Border.all(
                              color: isPanditSender ? Colors.transparent : AppTheme.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: Wrap(
                            children: [
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isPanditSender ? Colors.white : const Color(0xFFF0F3F8),
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type astrological guidance and remedies...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceTile,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          appState.sendChatMessage(val);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.cardPurple,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty) {
                          appState.sendChatMessage(_textController.text);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
