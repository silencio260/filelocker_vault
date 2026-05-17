import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/lockout_state_entity.dart';
import '../repositories/auth_base_repo.dart';

class RegisterFailedAttemptUseCase
    extends BaseUseCase<LockoutStateEntity, NoParams> {
  final AuthBaseRepo repo;
  RegisterFailedAttemptUseCase({required this.repo});

  @override
  Future<Either<Failure, LockoutStateEntity>> call(NoParams params) =>
      repo.registerFailedAttempt();
}
