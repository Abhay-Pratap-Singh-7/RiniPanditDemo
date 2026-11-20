import 'dart:async';
import 'package:flutter/material.dart';
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

  // State Variables
  UserProfile? _userProfile;
  List<Astrologer> _astrologers = [];
  List<WalletTransaction> _transactions = [];
  Horoscope? _currentHoroscope;
  KundliResult? _currentKundli;

  bool _isLoading = false;
  String? _errorMessage;

  // Active Consultation State
  ConsultationSession? _activeSession;
  Astrologer? _activeAstrologer;
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
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ConsultationSession? get activeSession => _activeSession;
  Astrologer? get activeAstrologer => _activeAstrologer;
  List<ChatMessage> get messages => _messages;
  int get activeSessionElapsedSeconds => _activeSessionElapsedSeconds;

  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Connect WebSocket
      _socket.connect();
      _listenToSocketEvents();

      // Fetch Profile, Astrologers, Horoscope
      await Future.wait([
        loadProfile(),
        loadAstrologers(),
        loadHoroscope('aries'),
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
      _activeSession = ConsultationSession.fromJson(data['session']);
      _activeAstrologer = Astrologer.fromJson(data['astrologer']);
      _messages = [];
      _activeSessionElapsedSeconds = 0;

      // Start local ticking timer for smooth UI seconds counter
      _localSecondsTimer?.cancel();
      _localSecondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _activeSessionElapsedSeconds++;
        notifyListeners();
      });

      notifyListeners();
    });

    _socket.onChatMessage.listen((msg) {
      _messages.add(msg);
      notifyListeners();
    });

    _socket.onBillingTick.listen((data) {
      if (_userProfile != null) {
        final newBal = (data['walletBalance'] as num?)?.toDouble() ?? _userProfile!.walletBalance;
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
      notifyListeners();
    });

    _socket.onConsultationEnded.listen((data) {
      _localSecondsTimer?.cancel();
      _activeSession = null;
      _activeAstrologer = null;
      loadProfile();
      notifyListeners();
    });

    _socket.onError.listen((msg) {
      _errorMessage = msg;
      notifyListeners();
    });
  }

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
