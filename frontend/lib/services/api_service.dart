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
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Auth & Role
  Future<Map<String, dynamic>> login({String? phone, String role = 'user'}) async {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone ?? '+919876543210',
      'role': role,
    });
    return response.data;
  }

  Future<Astrologer> panditLogin({String id = 'b0000000-0000-0000-0000-000000000001'}) async {
    final response = await _dio.post('/auth/pandit-login', data: {'id': id});
    return Astrologer.fromJson(response.data['data']);
  }

  // User & Profile
  Future<UserProfile> getUserProfile([String userId = ApiConstants.defaultUserId]) async {
    final response = await _dio.get('/user/profile', queryParameters: {'userId': userId});
    return UserProfile.fromJson(response.data['data']);
  }

  Future<UserProfile> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/user/profile', data: data);
    return UserProfile.fromJson(response.data['data']);
  }

  // Astrologers Marketplace
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

  // Pandit Dashboard Operations
  Future<Astrologer> getPanditProfile([String id = 'b0000000-0000-0000-0000-000000000001']) async {
    final response = await _dio.get('/pandit/profile', queryParameters: {'id': id});
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

  // Wallet
  Future<double> getWalletBalance([String userId = ApiConstants.defaultUserId]) async {
    final response = await _dio.get('/wallet/balance', queryParameters: {'userId': userId});
    return (response.data['data']['walletBalance'] as num).toDouble();
  }

  Future<double> rechargeWallet(double amount, [String userId = ApiConstants.defaultUserId]) async {
    final response = await _dio.post(
      '/wallet/recharge',
      data: {'userId': userId, 'amount': amount},
    );
    return (response.data['data']['newBalance'] as num).toDouble();
  }

  Future<List<WalletTransaction>> getTransactions([String userId = ApiConstants.defaultUserId]) async {
    final response = await _dio.get('/wallet/transactions', queryParameters: {'userId': userId});
    final list = response.data['data'] as List;
    return list.map((t) => WalletTransaction.fromJson(t)).toList();
  }

  // Consultations & Messages
  Future<List<ChatMessage>> getMessages(String consultationId) async {
    final response = await _dio.get('/consultations/$consultationId/messages');
    final list = response.data['data'] as List;
    return list.map((m) => ChatMessage.fromJson(m)).toList();
  }

  // Astrology Tools
  Future<Horoscope> getHoroscope(String sign) async {
    final response = await _dio.get('/astrology/horoscope', queryParameters: {'sign': sign});
    return Horoscope.fromJson(sign, response.data['data']);
  }

  Future<KundliResult> generateKundli(Map<String, dynamic> input) async {
    final response = await _dio.post('/astrology/kundli', data: input);
    return KundliResult.fromJson(response.data['data']);
  }
}
