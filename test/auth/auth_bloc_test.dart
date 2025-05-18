import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application/bloc/authentication/auth_bloc.dart';
import 'package:flutter_application/bloc/authentication/auth_event.dart';
import 'package:flutter_application/bloc/authentication/auth_state.dart';

import '../repository/mock_auth_repository.dart';



void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(mockAuthRepository);
  });

  tearDown(() async {
    await authBloc.close();
  });

  final testPerson = {'id': 1, 'namn': 'Test', 'personnummer': '1234567890'};

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoadingState, AuthenticatedState] on successful login',
    build: () {
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenAnswer((_) async => testPerson);
      return authBloc;
    },
    act: (bloc) {
      print("Running successful login test...");
      bloc.add(LoginEvent('Test', '1234567890'));
    },
    expect: () => [isA<AuthLoadingState>(), isA<AuthenticatedState>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoadingState, AuthErrorState] on login failure',
    build: () {
      when(
        () => mockAuthRepository.login(any(), any()),
      ).thenThrow(Exception('Login failed'));
      return authBloc;
    },
    act: (bloc) {
      print("Running failed login test...");
      bloc.add(LoginEvent('Test', 'wrong'));
    },
    expect: () => [isA<AuthLoadingState>(), isA<AuthErrorState>()],
  );
}
