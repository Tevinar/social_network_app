import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';

// Shared use case contract used across features to avoid duplicating the same
// abstract definition in each use case sub-layer.

/// Contract for a one-shot use case that requires input [Params].
abstract interface class UseCase<SuccessType, Params> {
  /// Executes the use case with [params].
  Future<Either<Failure, SuccessType>> call(Params params);
}

/// Contract for a one-shot use case that requires no input parameters.
abstract interface class NoParamsUseCase<SuccessType> {
  /// Executes the use case.
  Future<Either<Failure, SuccessType>> call();
}

/// Contract for a stream-based use case that requires input [Params].
abstract interface class StreamUseCase<Output, Params> {
  /// Starts the stream-based use case with [params].
  Stream<Output> call(Params params);
}

/// Contract for a stream-based use case that requires no input parameters.
abstract interface class NoParamsStreamUseCase<Output> {
  /// Starts the stream-based use case.
  Stream<Output> call();
}
