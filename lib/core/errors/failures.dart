sealed class Failure {
  final String message;
  Failure([this.message = 'An unexpected error has occured']);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class InvalidInputFailure extends Failure {
  InvalidInputFailure(super.message);
}
