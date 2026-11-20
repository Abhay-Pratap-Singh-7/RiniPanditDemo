import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/user_profile.dart';
import '../models/astrologer.dart';
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

  // User & Profile
  Future<UserProfile> getUserProfile([String userId = ApiConstants.defaultUserId]) async {
    final response = await _dio.get('/user/profile', queryParameters: {'userId': userId});
    return UserProfile.fromJson(response.data['data']);
  }

  Future<UserProfile> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/user/profile', data: data);
    return UserProfile.fromJson(response.data['data']);
  }

  // Astrologers
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
