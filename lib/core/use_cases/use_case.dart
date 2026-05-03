import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';

// Shared use case contract used across features to avoid duplicating the same
// abstract definition in each use case sub-layer.

abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract interface class NoParamsUseCase<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}

abstract interface class StreamUseCase<Output, Params> {
  Stream<Output> call(Params params);
}

abstract interface class NoParamsStreamUseCase<Output> {
  Stream<Output> call();
}
