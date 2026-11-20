import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../models/user_profile.dart';
import '../models/astrologer.dart';
import '../models/consultation.dart';
import '../models/chat_message.dart';
import '../models/wallet_transaction.dart';
import '../models/horoscope.dart';
import '../models/kundli_result.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();

  ApiService get api => _api;
  SocketService get socket => _socket;

  // Active Role ('user' | 'pandit')
  String _currentRole = 'user';
  String get currentRole => _currentRole;
  bool get isPandit => _currentRole == 'pandit';

  // Client State
  UserProfile? _userProfile;
  List<Astrologer> _astrologers = [];
  List<WalletTransaction> _transactions = [];
  Horoscope? _currentHoroscope;
  KundliResult? _currentKundli;

  // Pandit State
  Astrologer? _currentPandit;
  Map<String, dynamic> _panditEarnings = {};
  List<ConsultationSession> _panditSessions = [];
  Map<String, dynamic>? _incomingRequest;

  bool _isLoading = false;
  String? _errorMessage;

  // Active Consultation State
  ConsultationSession? _activeSession;
  Astrologer? _activeAstrologer;
  UserProfile? _activeConsultationUser;
  double _activeConsultationEarned = 0.0;
  List<ChatMessage> _messages = [];
  int _activeSessionElapsedSeconds = 0;
  Timer? _localSecondsTimer;

  // Getters
  UserProfile? get userProfile => _userProfile;
  double get walletBalance => _userProfile?.walletBalance ?? 0.0;
  List<Astrologer> get astrologers => _astrologers;
  List<WalletTransaction> get transactions => _transactions;
  Horoscope? get currentHoroscope => _currentHoroscope;
  KundliResult? get currentKundli => _currentKundli;

  Astrologer? get currentPandit => _currentPandit;
  Map<String, dynamic> get panditEarnings => _panditEarnings;
  List<ConsultationSession> get panditSessions => _panditSessions;
  Map<String, dynamic>? get incomingRequest => _incomingRequest;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ConsultationSession? get activeSession => _activeSession;
  Astrologer? get activeAstrologer => _activeAstrologer;
  UserProfile? get activeConsultationUser => _activeConsultationUser;
  double get activeConsultationEarned => _activeConsultationEarned;
  List<ChatMessage> get messages => _messages;
  int get activeSessionElapsedSeconds => _activeSessionElapsedSeconds;

  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      _listenToSocketEvents();

      // Initial socket connection as default user
      _socket.connect(ApiConstants.defaultUserId);

      // Fetch Initial User Data
      await Future.wait([
        loadProfile(),
        loadAstrologers(),
        loadHoroscope('aries'),
        loadPanditData('b0000000-0000-0000-0000-000000000001'),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToSocketEvents() {
    _socket.onConsultationStarted.listen((data) {
      _incomingRequest = null;
      _activeSession = ConsultationSession.fromJson(data['session']);
      if (data['astrologer'] != null) {
        _activeAstrologer = Astrologer.fromJson(data['astrologer']);
      }
      if (data['user'] != null) {
        _activeConsultationUser = UserProfile.fromJson(data['user']);
      }
      _messages = [];
      _activeSessionElapsedSeconds = 0;
      _activeConsultationEarned = _activeSession?.ratePerMinute ?? 0.0;

      // Start local ticking timer
      _localSecondsTimer?.cancel();
      _localSecondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _activeSessionElapsedSeconds++;
        notifyListeners();
      });

      notifyListeners();
    });

    _socket.onIncomingRequest.listen((data) {
      _incomingRequest = data;
      notifyListeners();
    });

    _socket.onChatMessage.listen((msg) {
      _messages.add(msg);
      notifyListeners();
    });

    _socket.onBillingTick.listen((data) {
      if (data['walletBalance'] != null && _userProfile != null) {
        final newBal = (data['walletBalance'] as num).toDouble();
        _userProfile = UserProfile(
          id: _userProfile!.id,
          phone: _userProfile!.phone,
          fullName: _userProfile!.fullName,
          gender: _userProfile!.gender,
          dob: _userProfile!.dob,
          tob: _userProfile!.tob,
          pobCity: _userProfile!.pobCity,
          pobCountry: _userProfile!.pobCountry,
          walletBalance: newBal,
          avatarUrl: _userProfile!.avatarUrl,
        );
      }

      if (data['earnedAmount'] != null) {
        _activeConsultationEarned = (data['earnedAmount'] as num).toDouble();
      }
      notifyListeners();
    });

    _socket.onConsultationEnded.listen((data) {
      _localSecondsTimer?.cancel();
      _activeSession = null;
      _activeAstrologer = null;
      _activeConsultationUser = null;
      _incomingRequest = null;
      if (isPandit) {
        loadPanditData();
      } else {
        loadProfile();
      }
      notifyListeners();
    });

    _socket.onError.listen((msg) {
      _errorMessage = msg;
      notifyListeners();
    });
  }

  // Role Management
  Future<void> switchRole(String role, {String? panditId}) async {
    _currentRole = role;
    _isLoading = true;
    notifyListeners();

    try {
      if (role == 'pandit') {
        final pid = panditId ?? _currentPandit?.id ?? 'b0000000-0000-0000-0000-000000000001';
        _currentPandit = await _api.panditLogin(id: pid);
        _socket.connect(pid);
        await loadPanditData(pid);
      } else {
        _socket.connect(ApiConstants.defaultUserId);
        await loadProfile();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pandit Operations
  Future<void> loadPanditData([String? id]) async {
    final panditId = id ?? _currentPandit?.id ?? 'b0000000-0000-0000-0000-000000000001';
    try {
      _currentPandit = await _api.getPanditProfile(panditId);
      _panditEarnings = await _api.getPanditEarnings(panditId);
      _panditSessions = await _api.getPanditSessions(panditId);
      notifyListeners();
    } catch (e) {
      // fallback
    }
  }

  Future<void> togglePanditOnline(bool isOnline) async {
    if (_currentPandit == null) return;
    try {
      _currentPandit = await _api.updatePanditStatus(
        id: _currentPandit!.id,
        isOnline: isOnline,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePanditRate(double newRate) async {
    if (_currentPandit == null) return;
    try {
      _currentPandit = await _api.updatePanditStatus(
        id: _currentPandit!.id,
        ratePerMinute: newRate,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void acceptIncomingRequest() {
    if (_incomingRequest != null) {
      final sessionId = _incomingRequest!['session']['id'];
      _socket.acceptConsultation(sessionId);
      _incomingRequest = null;
      notifyListeners();
    }
  }

  void declineIncomingRequest() {
    _incomingRequest = null;
    notifyListeners();
  }

  // Client Operations
  Future<void> loadProfile() async {
    try {
      _userProfile = await _api.getUserProfile();
      notifyListeners();
    } catch (e) {
      // fallback
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _api.updateUserProfile(data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAstrologers({String? specialty}) async {
    try {
      _astrologers = await _api.getAstrologers(specialty: specialty);
      notifyListeners();
    } catch (e) {
      // fallback
    }
  }

  Future<void> rechargeWallet(double amount) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newBal = await _api.rechargeWallet(amount);
      if (_userProfile != null) {
        _userProfile = UserProfile(
          id: _userProfile!.id,
          phone: _userProfile!.phone,
          fullName: _userProfile!.fullName,
          gender: _userProfile!.gender,
          dob: _userProfile!.dob,
          tob: _userProfile!.tob,
          pobCity: _userProfile!.pobCity,
          pobCountry: _userProfile!.pobCountry,
          walletBalance: newBal,
          avatarUrl: _userProfile!.avatarUrl,
        );
      }
      await loadTransactions();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await _api.getTransactions();
      notifyListeners();
    } catch (e) {
      // fallback
    }
  }

  Future<void> loadHoroscope(String sign) async {
    try {
      _currentHoroscope = await _api.getHoroscope(sign);
      notifyListeners();
    } catch (e) {
      // fallback
    }
  }

  Future<void> generateKundli(Map<String, dynamic> input) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentKundli = await _api.generateKundli(input);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startConsultation(String astrologerId) {
    _socket.initiateConsultation(astrologerId);
  }

  void sendChatMessage(String content) {
    if (_activeSession != null && content.trim().isNotEmpty) {
      _socket.sendMessage(_activeSession!.id, content.trim());
    }
  }

  void endActiveConsultation() {
    if (_activeSession != null) {
      _socket.endConsultation(_activeSession!.id);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _localSecondsTimer?.cancel();
    _socket.disconnect();
    super.dispose();
  }
}
