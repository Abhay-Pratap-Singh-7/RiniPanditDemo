import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/astrologer.dart';
import '../models/chat_message.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';

class ChatConsultationScreen extends StatefulWidget {
  final Astrologer astrologer;

  const ChatConsultationScreen({super.key, required this.astrologer});

  @override
  State<ChatConsultationScreen> createState() => _ChatConsultationScreenState();
}

class _ChatConsultationScreenState extends State<ChatConsultationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _declinedSub;
  StreamSubscription? _endedSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      _declinedSub = appState.socket.onConsultationDeclined.listen((data) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Pandit is currently unavailable or declined the request.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.pop(context);
      });

      _endedSub = appState.socket.onConsultationEnded.listen((data) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
            title: const Text(
              'Consultation Ended',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Text(
              data['message'] ?? 'The consultation session has ended.',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cardPurple),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _declinedSub?.cancel();
    _endedSub?.cancel();
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

  Widget _buildContent(AppState appState, List<ChatMessage> messages) {
    if (appState.activeSession == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.cardPurple.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.cardLilac.withAlpha(120), width: 2),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.cardLilac,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Waiting for Pandit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Invitation sent to ${widget.astrologer.displayName}.\nPlease wait while they accept your request...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.cardLilac,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Text(
                  'Rate: ₹${widget.astrologer.ratePerMinute.toStringAsFixed(0)}/min • Connection will establish once accepted',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
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
                'Live session ready with ${widget.astrologer.displayName}',
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
                  'Rate: ₹${widget.astrologer.ratePerMinute.toStringAsFixed(0)}/min • Timer and billing start on first message',
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
                'Send a message below to begin consultation.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.senderId == appState.userProfile?.id;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? AppTheme.cardPurple
                  : AppTheme.surfaceDark.withAlpha(230),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
              border: Border.all(
                color: isUser ? Colors.transparent : AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            child: Wrap(
              children: [
                Text(
                  msg.content,
                  style: TextStyle(
                    color: isUser ? Colors.white : const Color(0xFFF0F3F8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final messages = appState.messages;

    _scrollToBottom();

    return CosmicScaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.cardPurple.withAlpha(50),
              backgroundImage: widget.astrologer.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.astrologer.avatarUrl)
                  : null,
              child: widget.astrologer.avatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 20, color: AppTheme.cardLilac)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: [
                      Text(
                        widget.astrologer.displayName,
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
                        decoration: BoxDecoration(
                          color: appState.activeSession != null ? AppTheme.accentCyan : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          appState.activeSession != null
                              ? 'Connection Established • ₹${widget.astrologer.ratePerMinute.toStringAsFixed(0)}/min'
                              : 'Waiting for Pandit to accept...',
                          style: TextStyle(
                            fontSize: 11,
                            color: appState.activeSession != null ? AppTheme.cardLilac : Colors.amber.shade200,
                          ),
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
          // Live Timer Counter
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
            tooltip: 'End Consultation',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surfaceDark,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.cardRadius),
                  title: const Text('End Consultation', style: TextStyle(color: Colors.white)),
                  content: Text(
                    'Are you sure you want to end this live session with ${widget.astrologer.displayName}?',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.cardLilac)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('End Session', style: TextStyle(color: Colors.white)),
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
          // Real-time Billing & Wallet Ticker Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceTile.withAlpha(200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppTheme.cardLilac),
                    const SizedBox(width: 8),
                    Text(
                      'Wallet Balance: ₹${appState.walletBalance.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: appState.walletBalance < 50 ? Colors.redAccent : Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.cardPurple.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appState.isTimerRunning ? 'Billed Every 60s' : 'Billed on First Message',
                    style: const TextStyle(fontSize: 11, color: AppTheme.cardLilac, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages View
          Expanded(
            child: _buildContent(appState, messages),
          ),

          // Chat Input Bar
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
                      enabled: appState.activeSession != null,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: appState.activeSession != null
                            ? 'Ask about Kundli, career, relationships...'
                            : 'Waiting for Pandit to accept invitation...',
                        hintStyle: TextStyle(
                          color: appState.activeSession != null ? AppTheme.textMuted : AppTheme.textMuted.withAlpha(120),
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.surfaceTile,
                      ),
                      onSubmitted: (val) {
                        if (appState.activeSession != null && val.trim().isNotEmpty) {
                          appState.sendChatMessage(val);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: appState.activeSession != null
                        ? AppTheme.cardPurple
                        : AppTheme.surfaceTile,
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: appState.activeSession != null ? Colors.white : AppTheme.textMuted,
                        size: 18,
                      ),
                      onPressed: appState.activeSession != null
                          ? () {
                              if (_textController.text.trim().isNotEmpty) {
                                appState.sendChatMessage(_textController.text);
                                _textController.clear();
                              }
                            }
                          : null,
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
