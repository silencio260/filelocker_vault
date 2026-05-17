abstract class AuthBaseLocalDataSource {
  Future<bool> isFirstTime();
  Future<bool> setupPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<bool> isBiometricAvailable();
  Future<bool> isBiometricEnabled();
  Future<bool> enableBiometric();
  Future<bool> authenticateWithBiometric();
  Future<Map<String, dynamic>> getAuthState();
  Future<Map<String, dynamic>> getLockoutState();
  Future<Map<String, dynamic>> registerFailedAttempt();
  Future<bool> resetFailedAttempts();
  Future<bool> changePin(String currentPin, String newPin);
}
