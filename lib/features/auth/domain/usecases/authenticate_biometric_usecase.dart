import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_base_repo.dart';

class AuthenticateBiometricUseCase extends BaseUseCase<bool, NoParams> {
  final AuthBaseRepo repo;
  AuthenticateBiometricUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repo.authenticateWithBiometric();
}
