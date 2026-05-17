import 'package:dartz/dartz.dart';
import 'package:filelocker_vault/core/error/failure.dart';

abstract class BaseUseCase<Output, Input> {
  Future<Either<Failure, Output>> call(Input params);
}

class NoParams {
  const NoParams();
  static const instance = NoParams();
}
