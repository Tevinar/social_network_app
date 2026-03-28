import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';

// Shared use case contract used across features to avoid duplicating the same
// abstract definition in each use case sub-layer.
/// An use case.
// ignore: one_member_abstracts
abstract interface class UseCase<SuccessType, Params> {
  /// Executes the use case.
  Future<Either<Failure, SuccessType>> call(Params params);
  // A `call` method lets the instance itself be invoked like a function.
}

/// A no params.
class NoParams {}
