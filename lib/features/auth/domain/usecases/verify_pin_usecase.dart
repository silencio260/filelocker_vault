import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_base_repo.dart';

class VerifyPinParams extends Equatable {
  final String pin;
  const VerifyPinParams(this.pin);
  @override
  List<Object?> get props => [pin];
}

class VerifyPinUseCase extends BaseUseCase<bool, VerifyPinParams> {
  final AuthBaseRepo repo;
  VerifyPinUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(VerifyPinParams params) =>
      repo.verifyPin(params.pin);
}
