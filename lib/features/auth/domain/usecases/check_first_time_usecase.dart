import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_base_repo.dart';

class CheckFirstTimeUseCase extends BaseUseCase<bool, NoParams> {
  final AuthBaseRepo repo;
  CheckFirstTimeUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(NoParams params) => repo.isFirstTime();
}
