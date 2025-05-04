import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../repository/AuthRepository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final person = await authRepository.register(
        event.namn,
        event.personnummer,
      );
      emit(AuthenticatedState(person));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final person = await authRepository.login(event.namn, event.personnummer);
      emit(AuthenticatedState(person));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
