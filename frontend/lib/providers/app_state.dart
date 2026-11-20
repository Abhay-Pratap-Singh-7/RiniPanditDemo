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

  // Supabase Auth State
  String? _authToken;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  String? get authToken => _authToken;
  Map<String, dynamic>? get currentUser => _currentUser;

  // Active Role ('user' | 'pandit')
  String _currentRole = 'user';
  String get currentRole => _currentRole;
  bool get isPandit => _currentRole == 'pandit';

  // Client State
  UserProfile? _userProfile;
  List<Astrologer> _astrologers = [];
  List<WalletTransaction> _transactions = [];
  Map<String, Horoscope> _horoscopes = {};
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
  Map<String, Horoscope> get horoscopes => _horoscopes;
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

      // Load public marketplace and horoscope catalog
      await Future.wait([
        loadAstrologers(),
        loadAllHoroscopes(),
      ]);
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
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

  // ==========================================
  // SUPABASE AUTHENTICATION METHODS
  // ==========================================
  Future<bool> signUpWithSupabase({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    String role = 'user',
    List<String>? specialties,
    double? ratePerMinute,
    int? experienceYears,
    String? bio,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.signUpWithSupabase(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        specialties: role == 'pandit' ? specialties : null,
        ratePerMinute: role == 'pandit' ? ratePerMinute : null,
        experienceYears: role == 'pandit' ? experienceYears : null,
        bio: role == 'pandit' ? bio : null,
      );

      if (res['success'] == true) {
        _authToken = res['token'] as String?;
        _isAuthenticated = true;
        _currentUser = res['user'] as Map<String, dynamic>?;
        _currentRole = role;

        if (res['profile'] != null) {
          _userProfile = UserProfile.fromJson(res['profile']);
        }
        if (res['astrologer'] != null) {
          _currentPandit = Astrologer.fromJson(res['astrologer']);
        }

        // Reconnect socket with authenticated user ID
        final uid = _userProfile?.id ?? _currentUser?['id'] ?? ApiConstants.defaultUserId;
        _socket.connect(uid.toString());

        await loadProfile();
        if (isPandit) {
          await loadPanditData(_currentPandit?.id ?? _userProfile?.id);
        }
        return true;
      } else {
        _errorMessage = ApiService.extractErrorMessage(res['message'] ?? 'Sign up failed');
        return false;
      }
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithSupabase({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.signInWithSupabase(
        email: email,
        password: password,
      );

      if (res['success'] == true) {
        _authToken = res['token'] as String?;
        _isAuthenticated = true;
        _currentUser = res['user'] as Map<String, dynamic>?;

        final role = (res['role'] as String?) ??
            (res['user']?['role'] as String?) ??
            (res['user']?['user_metadata']?['role'] as String?) ??
            (res['astrologer'] != null ? 'pandit' : 'user');
        _currentRole = role;

        if (res['profile'] != null) {
          _userProfile = UserProfile.fromJson(res['profile']);
        }
        if (res['astrologer'] != null) {
          _currentPandit = Astrologer.fromJson(res['astrologer']);
        }

        // Reconnect socket with authenticated user ID
        final uid = _userProfile?.id ?? _currentUser?['id'] ?? ApiConstants.defaultUserId;
        _socket.connect(uid.toString());

        await loadProfile();
        if (isPandit) {
          await loadPanditData(_currentPandit?.id ?? _userProfile?.id);
        }
        return true;
      } else {
        _errorMessage = ApiService.extractErrorMessage(res['message'] ?? 'Invalid credentials');
        return false;
      }
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _api.signOut();
      _authToken = null;
      _isAuthenticated = false;
      _currentUser = null;
      _currentRole = 'user';
      _userProfile = null;
      _currentPandit = null;
      _socket.connect(ApiConstants.defaultUserId);
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Role Management
  Future<void> switchRole(String role, {String? panditId}) async {
    _currentRole = role;
    _isLoading = true;
    notifyListeners();

    try {
      if (role == 'pandit') {
        final pid = panditId ?? _currentPandit?.id ?? _currentUser?['id'] ?? _userProfile?.id;
        if (pid != null) {
          _currentPandit = await _api.panditLogin(id: pid);
          _socket.connect(pid);
          await loadPanditData(pid);
        }
      } else {
        final uid = _userProfile?.id ?? _currentUser?['id'] ?? '';
        if (uid.isNotEmpty) {
          _socket.connect(uid);
          await loadProfile();
        }
      }
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pandit Operations
  Future<void> loadPanditData([String? id]) async {
    final panditId = id ?? _currentPandit?.id ?? _userProfile?.id ?? _currentUser?['id'];
    if (panditId == null) return;
    try {
      _currentPandit = await _api.getPanditProfile(panditId);
      _panditEarnings = await _api.getPanditEarnings(panditId);
      _panditSessions = await _api.getPanditSessions(panditId);
      notifyListeners();
    } catch (_) {}
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
      _errorMessage = ApiService.extractErrorMessage(e);
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
      _errorMessage = ApiService.extractErrorMessage(e);
      notifyListeners();
    }
  }

  Future<bool> updatePanditProfile({
    required double ratePerMinute,
    required String bio,
    required List<String> specialties,
    int? experienceYears,
    String? displayName,
  }) async {
    final pid = _currentPandit?.id ?? _userProfile?.id ?? _currentUser?['id'];
    if (pid == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final name = displayName ?? _userProfile?.fullName ?? _currentUser?['user_metadata']?['full_name'] ?? 'Acharya';
      _currentPandit = await _api.updatePanditStatus(
        id: pid,
        ratePerMinute: ratePerMinute,
        bio: bio,
        specialties: specialties,
        experienceYears: experienceYears,
        displayName: name,
      );
      try {
        await loadPanditData(pid);
      } catch (_) {}
      return true;
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
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
    } catch (_) {}
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _api.updateUserProfile(data);
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAstrologers({String? specialty}) async {
    try {
      _astrologers = await _api.getAstrologers(specialty: specialty);
      notifyListeners();
    } catch (_) {}
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
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _transactions = await _api.getTransactions();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadAllHoroscopes() async {
    try {
      _horoscopes = await _api.getAllHoroscopes();
      if (_horoscopes.isNotEmpty && _currentHoroscope == null) {
        _currentHoroscope = _horoscopes.values.first;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadHoroscope(String sign) async {
    try {
      _currentHoroscope = await _api.getHoroscope(sign);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> generateKundli(Map<String, dynamic> birthDetails) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentKundli = await _api.generateKundli(birthDetails);
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Consultation Actions
  void startConsultation(String astrologerId) {
    _socket.initiateConsultation(astrologerId);
  }

  void endConsultation() {
    endActiveConsultation();
  }

  void endActiveConsultation() {
    if (_activeSession != null) {
      _socket.endConsultation(_activeSession!.id);
      _localSecondsTimer?.cancel();
      _activeSession = null;
      _activeAstrologer = null;
      _activeConsultationUser = null;
      notifyListeners();
    }
  }

  void sendMessage(String content) {
    sendChatMessage(content);
  }

  void sendChatMessage(String content) {
    if (_activeSession != null && content.trim().isNotEmpty) {
      _socket.sendMessage(_activeSession!.id, content.trim());
    }
  }

  @override
  void dispose() {
    _localSecondsTimer?.cancel();
    _socket.disconnect();
    super.dispose();
  }
}
