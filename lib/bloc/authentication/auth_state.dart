abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final Map<String, dynamic> person;

  AuthenticatedState(this.person);
}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);
}
