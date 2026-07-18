import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  const AuthRepositoryImpl({
    required this.apiClient,
    required this.tokenStorage,
  });

  @override
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    final dynamic response = await apiClient.post(
      ApiEndpoints.login,
      requiresAuth: false,
      useAuthBaseUrl: true,
      body: {
        'phone': phone,
        'password': password,
      },
    );

    final Map<String, dynamic> root = ApiParser.asMap(
      response,
      unwrap: false,
    );

    Map<String, dynamic> data = <String, dynamic>{};

    if (root['data'] is Map) {
      data = Map<String, dynamic>.from(
        root['data'] as Map,
      );
    }

    final String? token =
        data['token']?.toString() ??
            data['accessToken']?.toString() ??
            data['access_token']?.toString() ??
            root['token']?.toString() ??
            root['accessToken']?.toString() ??
            root['access_token']?.toString();

    if (token == null || token.trim().isEmpty) {
      throw const ApiException(
        message:
        'The login response does not contain a token.',
      );
    }

    await tokenStorage.saveToken(token);
  }

  @override
  Future<void> logout() {
    return tokenStorage.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() {
    return tokenStorage.hasToken();
  }
}