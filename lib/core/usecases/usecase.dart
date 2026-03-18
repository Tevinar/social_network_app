import 'package:social_app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

//We create here a generic interface to avoid creating the same abstract class for each feature in the use cases sub-layer
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
  //Note : when a method is called 'call' in a class, it means that you can call this method directly with the name
  //of an instance of the class.
}

class NoParams {}
