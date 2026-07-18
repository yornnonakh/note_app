abstract class AuthRepository {
  Future<void> login({
    required String phone,
    required String password,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();
}