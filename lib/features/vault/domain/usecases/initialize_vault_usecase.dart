import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/vault_base_repo.dart';

class InitializeVaultUseCase extends BaseUseCase<bool, NoParams> {
  final VaultBaseRepo repo;
  InitializeVaultUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repo.initializeVault();
}
