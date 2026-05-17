import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_base_repo.dart';

class GetAuthStateUseCase extends BaseUseCase<AuthEntity, NoParams> {
  final AuthBaseRepo repo;
  GetAuthStateUseCase({required this.repo});

  @override
  Future<Either<Failure, AuthEntity>> call(NoParams params) =>
      repo.getAuthState();
}
