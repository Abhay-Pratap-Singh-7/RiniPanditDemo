import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/user_profile.dart';
import '../models/astrologer.dart';
import '../models/consultation.dart';
import '../models/wallet_transaction.dart';
import '../models/chat_message.dart';
import '../models/horoscope.dart';
import '../models/kundli_result.dart';

class ApiService {
  late final Dio _dio;
  String? _authToken;

  String? get authToken => _authToken;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  // ==========================================
  // SUPABASE AUTHENTICATION APIS
  // ==========================================
  Future<Map<String, dynamic>> signUpWithSupabase({
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
    final response = await _dio.post('/auth/signup', data: {
      'email': email,
      'password': password,
      'fullName': fullName ?? 'Devotee / Client',
      'phone': phone ?? '+919876543210',
      'role': role,
      'specialties': specialties ?? ['Vedic', 'Kundli'],
      'ratePerMinute': ratePerMinute ?? 25.0,
      'experienceYears': experienceYears ?? 5,
      'bio': bio ?? '',
    });
    if (response.data['token'] != null) {
      setAuthToken(response.data['token'] as String);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> signInWithSupabase({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    if (response.data['token'] != null) {
      setAuthToken(response.data['token'] as String);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  Future<void> signOut() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    setAuthToken(null);
  }

  Future<Astrologer> panditLogin({String id = 'b0000000-0000-0000-0000-000000000001'}) async {
    final response = await _dio.post('/auth/pandit-login', data: {'id': id});
    return Astrologer.fromJson(response.data['data']);
  }

  // ==========================================
  // USER & PROFILE
  // ==========================================
  Future<UserProfile> getUserProfile([String? userId]) async {
    final response = await _dio.get(
      '/user/profile',
      queryParameters: userId != null ? {'userId': userId} : null,
    );
    return UserProfile.fromJson(response.data['data']);
  }

  Future<UserProfile> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/user/profile', data: data);
    return UserProfile.fromJson(response.data['data']);
  }

  // ==========================================
  // ASTROLOGERS MARKETPLACE
  // ==========================================
  Future<List<Astrologer>> getAstrologers({String? specialty}) async {
    final response = await _dio.get(
      '/astrologers',
      queryParameters: specialty != null ? {'specialty': specialty} : null,
    );
    final list = response.data['data'] as List;
    return list.map((a) => Astrologer.fromJson(a)).toList();
  }

  Future<Astrologer> getAstrologer(String id) async {
    final response = await _dio.get('/astrologers/$id');
    return Astrologer.fromJson(response.data['data']);
  }

  // ==========================================
  // PANDIT DASHBOARD
  // ==========================================
  Future<Astrologer> getPanditProfile([String? id]) async {
    final response = await _dio.get(
      '/pandit/profile',
      queryParameters: id != null ? {'id': id} : null,
    );
    return Astrologer.fromJson(response.data['data']);
  }

  Future<Astrologer> updatePanditStatus({
    required String id,
    bool? isOnline,
    bool? isBusy,
    double? ratePerMinute,
  }) async {
    final Map<String, dynamic> body = {'id': id};
    if (isOnline != null) body['isOnline'] = isOnline;
    if (isBusy != null) body['isBusy'] = isBusy;
    if (ratePerMinute != null) body['ratePerMinute'] = ratePerMinute;
    final response = await _dio.put('/pandit/status', data: body);
    return Astrologer.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getPanditEarnings(String id) async {
    final response = await _dio.get('/pandit/earnings/$id');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<ConsultationSession>> getPanditSessions(String id) async {
    final response = await _dio.get('/pandit/sessions/$id');
    final list = response.data['data'] as List;
    return list.map((s) => ConsultationSession.fromJson(s)).toList();
  }

  // ==========================================
  // WALLET
  // ==========================================
  Future<double> getWalletBalance([String? userId]) async {
    final response = await _dio.get(
      '/wallet/balance',
      queryParameters: userId != null ? {'userId': userId} : null,
    );
    return (response.data['data']['walletBalance'] as num).toDouble();
  }

  Future<double> rechargeWallet(double amount, [String? userId]) async {
    final Map<String, dynamic> body = {'amount': amount};
    if (userId != null) body['userId'] = userId;
    final response = await _dio.post('/wallet/recharge', data: body);
    return (response.data['data']['newBalance'] as num).toDouble();
  }

  Future<List<WalletTransaction>> getTransactions([String? userId]) async {
    final response = await _dio.get(
      '/wallet/transactions',
      queryParameters: userId != null ? {'userId': userId} : null,
    );
    final list = response.data['data'] as List;
    return list.map((t) => WalletTransaction.fromJson(t)).toList();
  }

  // ==========================================
  // CONSULTATIONS & MESSAGES
  // ==========================================
  Future<List<ChatMessage>> getMessages(String consultationId) async {
    final response = await _dio.get('/consultations/$consultationId/messages');
    final list = response.data['data'] as List;
    return list.map((m) => ChatMessage.fromJson(m)).toList();
  }

  // ==========================================
  // ASTROLOGY TOOLS
  // ==========================================
  Future<Map<String, Horoscope>> getAllHoroscopes() async {
    final response = await _dio.get('/astrology/horoscopes');
    final data = response.data['data'] as Map<String, dynamic>;
    return data.map((key, val) => MapEntry(key, Horoscope.fromJson(key, val as Map<String, dynamic>)));
  }

  Future<Horoscope> getHoroscope(String sign, [String timeframe = 'daily']) async {
    final response = await _dio.get('/astrology/horoscope', queryParameters: {
      'sign': sign,
      'timeframe': timeframe,
    });
    return Horoscope.fromJson(sign, response.data['data'] as Map<String, dynamic>);
  }

  Future<KundliResult> generateKundli(Map<String, dynamic> birthDetails) async {
    final response = await _dio.post('/astrology/kundli', data: birthDetails);
    return KundliResult.fromJson(response.data['data']);
  }
}
