import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';

class SocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Stream Controllers
  final _startedController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _tickController = StreamController<Map<String, dynamic>>.broadcast();
  final _endedController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get onConsultationStarted => _startedController.stream;
  Stream<ChatMessage> get onChatMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onBillingTick => _tickController.stream;
  Stream<Map<String, dynamic>> get onConsultationEnded => _endedController.stream;
  Stream<String> get onError => _errorController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect([String userId = ApiConstants.defaultUserId]) {
    if (_isConnected) return;

    final uri = Uri.parse('${ApiConstants.wsUrl}?userId=$userId');
    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final parsed = jsonDecode(data as String);
            final event = parsed['event'];
            final payload = parsed['data'];

            switch (event) {
              case 'consultation:started':
                _startedController.add(payload);
                break;
              case 'chat:message':
                _messageController.add(ChatMessage.fromJson(payload));
                break;
              case 'billing:tick':
                _tickController.add(payload);
                break;
              case 'consultation:ended':
                _endedController.add(payload);
                break;
              case 'error':
                _errorController.add(payload['message'] ?? 'An error occurred');
                break;
            }
          } catch (e) {
            // parsing error
          }
        },
        onError: (err) {
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
    }
  }

  void initiateConsultation(String astrologerId) {
    if (!_isConnected) connect();
    _channel?.sink.add(jsonEncode({
      'event': 'consultation:initiate',
      'data': {'astrologerId': astrologerId},
    }));
  }

  void sendMessage(String sessionId, String content) {
    if (!_isConnected) connect();
    _channel?.sink.add(jsonEncode({
      'event': 'chat:send',
      'data': {
        'sessionId': sessionId,
        'content': content,
      },
    }));
  }

  void endConsultation(String sessionId) {
    if (!_isConnected) return;
    _channel?.sink.add(jsonEncode({
      'event': 'consultation:end',
      'data': {'sessionId': sessionId},
    }));
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }
}
