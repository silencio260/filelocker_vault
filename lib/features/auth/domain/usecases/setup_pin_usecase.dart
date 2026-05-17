import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/auth_base_repo.dart';

class SetupPinParams extends Equatable {
  final String pin;
  const SetupPinParams(this.pin);
  @override
  List<Object?> get props => [pin];
}

class SetupPinUseCase extends BaseUseCase<bool, SetupPinParams> {
  final AuthBaseRepo repo;
  SetupPinUseCase({required this.repo});

  @override
  Future<Either<Failure, bool>> call(SetupPinParams params) =>
      repo.setupPin(params.pin);
}
