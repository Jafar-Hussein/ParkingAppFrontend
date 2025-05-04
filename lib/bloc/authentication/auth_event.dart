abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String namn;
  final String personnummer;

  RegisterEvent(this.namn, this.personnummer);
}

class LoginEvent extends AuthEvent {
  final String namn;
  final String personnummer;

  LoginEvent(this.namn, this.personnummer);
}
