import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isRestoringSession = true;
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoringSession => _isRestoringSession;
  String? get authToken => _authToken;
  Map<String, dynamic>? get currentUser => _currentUser;

  // Active Role ('user' | 'pandit')
  String _currentRole = 'user';
  String get currentRole => _currentRole;
  bool get isPandit => _currentRole == 'pandit';

  // Client State
  UserProfile? _userProfile;
  List<Astrologer> _astrologers = [];
  bool _isLoadingAstrologers = false;
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
  bool _isTimerRunning = false;
  bool _isWaitingForPandit = false;
  Timer? _localSecondsTimer;

  // Getters
  UserProfile? get userProfile => _userProfile;
  double get walletBalance => _userProfile?.walletBalance ?? 0.0;
  List<Astrologer> get astrologers => _astrologers;
  bool get isLoadingAstrologers => _isLoadingAstrologers;
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
  bool get isTimerRunning => _isTimerRunning;
  bool get isWaitingForPandit => _isWaitingForPandit;

  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    _isLoading = true;
    _isRestoringSession = true;
    notifyListeners();

    try {
      _listenToSocketEvents();

      await _restoreSession();

      if (!_socket.isConnected) {
        final uid = _userProfile?.id ?? _currentUser?['id']?.toString() ?? ApiConstants.defaultUserId;
        _socket.connect(uid);
      }

      // Load public marketplace and horoscope catalog
      await Future.wait([
        loadAstrologers(),
        loadAllHoroscopes(),
      ]);
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      _isLoading = false;
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final role = prefs.getString('user_role') ?? 'user';
      final userId = prefs.getString('user_id');
      final email = prefs.getString('user_email');

      if (token != null && token.isNotEmpty) {
        _authToken = token;
        _api.setAuthToken(token);
        _isAuthenticated = true;
        _currentRole = role;

        if (userId != null) {
          _currentUser = {
            'id': userId,
            'email': email ?? '',
            'role': role,
          };
        }

        final uid = userId ?? ApiConstants.defaultUserId;
        _socket.connect(uid);

        try {
          final meRes = await _api.getMe();
          if (meRes['success'] == true) {
            if (meRes['user'] != null) {
              _currentUser = meRes['user'] as Map<String, dynamic>?;
            }
            if (meRes['role'] != null) {
              _currentRole = meRes['role'] as String;
              await prefs.setString('user_role', _currentRole);
            }
            if (meRes['profile'] != null) {
              _userProfile = UserProfile.fromJson(meRes['profile']);
            }
            if (meRes['astrologer'] != null) {
              _currentPandit = Astrologer.fromJson(meRes['astrologer']);
            }
          }
        } catch (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('401') || errStr.contains('unauthorized')) {
            await logout();
            return;
          }
        }

        if (isPandit) {
          await loadPanditData(_currentPandit?.id ?? _userProfile?.id ?? userId);
        } else {
          await loadProfile();
        }
      }
    } catch (e) {
      debugPrint('[AppState] Failed to restore session: $e');
    }
  }

  Future<void> _saveSession({
    required String token,
    required String role,
    required String userId,
    String? email,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role);
      await prefs.setString('user_id', userId);
      if (email != null && email.isNotEmpty) {
        await prefs.setString('user_email', email);
      }
    } catch (e) {
      debugPrint('[AppState] Failed to save session: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
    } catch (e) {
      debugPrint('[AppState] Failed to clear session: $e');
    }
  }

  void _listenToSocketEvents() {
    _socket.onConsultationWaiting.listen((data) {
      _isWaitingForPandit = true;
      notifyListeners();
    });

    _socket.onConsultationStarted.listen((data) {
      _incomingRequest = null;
      _isWaitingForPandit = false;
      _activeSession = ConsultationSession.fromJson(data['session']);
      if (data['astrologer'] != null) {
        _activeAstrologer = Astrologer.fromJson(data['astrologer']);
      }
      if (data['user'] != null) {
        _activeConsultationUser = UserProfile.fromJson(data['user']);
      }
      _messages = [];
      _activeSessionElapsedSeconds = 0;
      _activeConsultationEarned = 0.0;
      _isTimerRunning = false;
      _localSecondsTimer?.cancel();
      _localSecondsTimer = null;

      notifyListeners();
    });

    _socket.onConsultationDeclined.listen((data) {
      _isWaitingForPandit = false;
      _activeSession = null;
      _errorMessage = data['message'] ?? 'Pandit is unavailable or declined the request.';
      notifyListeners();
    });

    _socket.onTimerStarted.listen((data) {
      _startTimer();
    });

    _socket.onIncomingRequest.listen((data) {
      _incomingRequest = data;
      notifyListeners();
    });

    _socket.onChatMessage.listen((msg) {
      _messages.add(msg);
      if (!_isTimerRunning && _activeSession != null) {
        String? clientUserId = _activeConsultationUser?.id;
        if (clientUserId == null && _currentRole != 'pandit') {
          clientUserId = _currentUser?['id']?.toString();
        }
        if (clientUserId != null && msg.senderId == clientUserId) {
          _startTimer();
        }
      }
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

      if (isPandit) {
        final currentTotal = (_panditEarnings['totalEarned'] as num?)?.toDouble() ?? 0.0;
        final earned = (data['earnedAmount'] as num?)?.toDouble() ?? 0.0;
        final newBal = (data['walletBalance'] as num?)?.toDouble();
        _panditEarnings = {
          ..._panditEarnings,
          'totalEarned': newBal ?? (currentTotal + earned),
          'walletBalance': newBal ?? (currentTotal + earned),
        };
      }

      notifyListeners();
    });

    _socket.onConsultationEnded.listen((data) {
      _localSecondsTimer?.cancel();
      _localSecondsTimer = null;
      _isTimerRunning = false;
      _activeSessionElapsedSeconds = 0;
      _activeConsultationEarned = 0.0;
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

    _socket.onAstrologerStatus.listen((data) {
      final astroId = data['astrologerId']?.toString();
      final isOnline = data['isOnline'] as bool?;
      final isBusy = (data['isBusy'] ?? data['busy']) as bool?;

      if (astroId != null) {
        final index = _astrologers.indexWhere((a) => a.id == astroId);
        if (index != -1) {
          final current = _astrologers[index];
          _astrologers[index] = current.copyWith(
            isOnline: isOnline ?? current.isOnline,
            isBusy: isBusy ?? current.isBusy,
          );
        }

        if (_activeAstrologer != null && _activeAstrologer!.id == astroId) {
          _activeAstrologer = _activeAstrologer!.copyWith(
            isOnline: isOnline ?? _activeAstrologer!.isOnline,
            isBusy: isBusy ?? _activeAstrologer!.isBusy,
          );
        }

        if (_currentPandit != null && _currentPandit!.id == astroId) {
          _currentPandit = _currentPandit!.copyWith(
            isOnline: isOnline ?? _currentPandit!.isOnline,
            isBusy: isBusy ?? _currentPandit!.isBusy,
          );
        }

        notifyListeners();
      }
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

        if (_authToken != null && _authToken!.isNotEmpty) {
          await _saveSession(
            token: _authToken!,
            role: _currentRole,
            userId: uid.toString(),
            email: email,
          );
        }

        _socket.connect(uid.toString());

        await loadProfile();
        await loadAstrologers();
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

        if (_authToken != null && _authToken!.isNotEmpty) {
          await _saveSession(
            token: _authToken!,
            role: _currentRole,
            userId: uid.toString(),
            email: email,
          );
        }

        _socket.connect(uid.toString());

        await loadProfile();
        await loadAstrologers();
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
    } catch (e) {
      _errorMessage = ApiService.extractErrorMessage(e);
    } finally {
      await _clearSession();
      _authToken = null;
      _isAuthenticated = false;
      _currentUser = null;
      _currentRole = 'user';
      _userProfile = null;
      _currentPandit = null;
      _socket.connect(ApiConstants.defaultUserId);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);
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
      _currentPandit = _currentPandit!.copyWith(isOnline: isOnline);
      notifyListeners();

      _socket.updateAstrologerStatus(
        astrologerId: _currentPandit!.id,
        isOnline: isOnline,
      );

      final updated = await _api.updatePanditStatus(
        id: _currentPandit!.id,
        isOnline: isOnline,
      );
      _currentPandit = updated;
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
      final sessionMap = _incomingRequest!['session'];
      if (sessionMap is Map<String, dynamic>) {
        _activeSession = ConsultationSession.fromJson(sessionMap);
      }
      if (_incomingRequest!['user'] is Map<String, dynamic>) {
        _activeConsultationUser = UserProfile.fromJson(_incomingRequest!['user']);
      }
      if (_incomingRequest!['astrologer'] is Map<String, dynamic>) {
        _activeAstrologer = Astrologer.fromJson(_incomingRequest!['astrologer']);
      }
      final sessionId = sessionMap?['id'];
      if (sessionId != null) {
        _socket.acceptConsultation(sessionId.toString());
      }
      _incomingRequest = null;
      notifyListeners();
    }
  }

  void declineIncomingRequest() {
    if (_incomingRequest != null) {
      final sessionId = _incomingRequest!['session']?['id'];
      if (sessionId != null) {
        _socket.declineConsultation(sessionId.toString());
      }
      _incomingRequest = null;
      notifyListeners();
    }
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
    _isLoadingAstrologers = true;
    notifyListeners();
    try {
      _astrologers = await _api.getAstrologers(specialty: specialty);
    } catch (_) {}
    finally {
      _isLoadingAstrologers = false;
      notifyListeners();
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
    _isWaitingForPandit = true;
    _activeSession = null;
    _activeSessionElapsedSeconds = 0;
    _activeConsultationEarned = 0.0;
    _isTimerRunning = false;
    _localSecondsTimer?.cancel();
    _localSecondsTimer = null;
    _socket.initiateConsultation(astrologerId);
    notifyListeners();
  }

  void endConsultation() {
    endActiveConsultation();
  }

  void endActiveConsultation() {
    if (_activeSession != null) {
      _socket.endConsultation(_activeSession!.id);
    }
    _isWaitingForPandit = false;
    _localSecondsTimer?.cancel();
    _localSecondsTimer = null;
    _isTimerRunning = false;
    _activeSessionElapsedSeconds = 0;
    _activeConsultationEarned = 0.0;
    _activeSession = null;
    _activeAstrologer = null;
    _activeConsultationUser = null;
    notifyListeners();
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _activeSessionElapsedSeconds = 0;
    _localSecondsTimer?.cancel();
    _localSecondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _activeSessionElapsedSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void sendMessage(String content) {
    sendChatMessage(content);
  }

  void sendChatMessage(String content) {
    if (_activeSession != null && content.trim().isNotEmpty) {
      _socket.sendMessage(_activeSession!.id, content.trim());
      if (!_isTimerRunning && !isPandit) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _localSecondsTimer?.cancel();
    _socket.disconnect();
    super.dispose();
  }
}
