import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_base_repo.dart';

class ChangePinParams extends Equatable {
  final String currentPin;
  final String newPin;
  const ChangePinParams({required this.currentPin, required this.newPin});
  @override
  List<Object?> get props => [currentPin, newPin];
}

class ChangePinUseCase extends BaseUseCase<bool, ChangePinParams> {
  final AuthBaseRepo repo;
  ChangePinUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(ChangePinParams params) =>
      repo.changePin(params.currentPin, params.newPin);
}
