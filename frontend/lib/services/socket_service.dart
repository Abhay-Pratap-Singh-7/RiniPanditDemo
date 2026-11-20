import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_constants.dart';
import '../models/chat_message.dart';

class SocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _currentUserId;

  // Stream Controllers
  final _startedController = StreamController<Map<String, dynamic>>.broadcast();
  final _incomingRequestController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _tickController = StreamController<Map<String, dynamic>>.broadcast();
  final _endedController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<Map<String, dynamic>> get onConsultationStarted => _startedController.stream;
  Stream<Map<String, dynamic>> get onIncomingRequest => _incomingRequestController.stream;
  Stream<ChatMessage> get onChatMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onBillingTick => _tickController.stream;
  Stream<Map<String, dynamic>> get onConsultationEnded => _endedController.stream;
  Stream<String> get onError => _errorController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect([String? userId]) {
    final uid = userId ?? _currentUserId ?? ApiConstants.defaultUserId;
    if (_isConnected && _currentUserId == uid) return;

    if (_isConnected) {
      disconnect();
    }

    _currentUserId = uid;
    final uri = Uri.parse('${ApiConstants.wsUrl}?userId=$uid');
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
              case 'consultation:incoming_request':
                _incomingRequestController.add(payload);
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
    final payload = jsonEncode({
      'event': 'consultation:initiate',
      'data': {'astrologerId': astrologerId},
    });

    if (!_isConnected) {
      connect();
      Future.delayed(const Duration(milliseconds: 300), () {
        _channel?.sink.add(payload);
      });
      return;
    }
    _channel?.sink.add(payload);
  }

  void acceptConsultation(String sessionId) {
    final payload = jsonEncode({
      'event': 'consultation:accept',
      'data': {'sessionId': sessionId},
    });

    if (!_isConnected) {
      connect();
      Future.delayed(const Duration(milliseconds: 300), () {
        _channel?.sink.add(payload);
      });
      return;
    }
    _channel?.sink.add(payload);
  }

  void sendMessage(String sessionId, String content) {
    final payload = jsonEncode({
      'event': 'chat:send',
      'data': {
        'sessionId': sessionId,
        'content': content,
      },
    });

    if (!_isConnected) {
      connect();
      Future.delayed(const Duration(milliseconds: 300), () {
        _channel?.sink.add(payload);
      });
      return;
    }
    _channel?.sink.add(payload);
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
    _currentUserId = null;
  }
}
