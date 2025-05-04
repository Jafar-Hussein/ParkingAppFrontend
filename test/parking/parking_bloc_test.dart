import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application/bloc/parking/parking_bloc.dart';
import 'package:flutter_application/bloc/parking/parking_event.dart';
import 'package:flutter_application/bloc/parking/parking_state.dart';
import 'package:flutter_application/repository/parkingRepository.dart';

import '../repository/mock_parking_repository.dart';



void main() {
  late ParkingBloc bloc;
  late MockParkingRepository mockRepo;

  setUp(() {
    mockRepo = MockParkingRepository();
    bloc = ParkingBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  group('ParkingBloc', () {
    blocTest<ParkingBloc, ParkingState>(
      'LoadParkingDataEvent success → emits [loading, loaded]',
      build: () {
        when(() => mockRepo.getParkingHistory()).thenAnswer((_) async {
          print('getParkingHistory called → returns []');
          return [];
        });
        when(() => mockRepo.getAvailableSpaces()).thenAnswer((_) async {
          print('getAvailableSpaces called → returns []');
          return [];
        });
        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async {
          print('getVehicles("test") called → returns []');
          return [];
        });
        return bloc;
      },
      act: (bloc) {
        print('Sending event: LoadParkingDataEvent("test")');
        bloc.add(LoadParkingDataEvent('test'));
      },
      expect: () {
        print('Expecting: Loading then Loaded with empty data');
        return [
          isA<ParkingState>().having((s) => s.isLoading, 'isLoading', true),
          isA<ParkingState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.parkingHistory, 'parkingHistory', [])
              .having((s) => s.availableSpaces, 'availableSpaces', [])
              .having((s) => s.vehicles, 'vehicles', []),
        ];
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'LoadParkingDataEvent failure → emits error state',
      build: () {
        when(() => mockRepo.getParkingHistory()).thenThrow(Exception('Failed'));
        when(() => mockRepo.getAvailableSpaces()).thenAnswer((_) async => []);
        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) {
        print('Sending event: LoadParkingDataEvent("test") (with error)');
        bloc.add(LoadParkingDataEvent('test'));
      },
      expect: () {
        print('Expecting: Loading then Error state');
        return [
          isA<ParkingState>().having((s) => s.isLoading, 'isLoading', true),
          isA<ParkingState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Failed'),
              ),
        ];
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'StartParkingEvent failure → emits error state',
      build: () {
        when(
          () => mockRepo.startParking(any(), any(), any()),
        ).thenThrow(Exception('Start failed'));
        return bloc;
      },
      act: (bloc) {
        print('Sending event: StartParkingEvent');
        bloc.add(StartParkingEvent(1, {'vehicle': 'ABC123'}, 'test'));
      },
      expect: () {
        print('Expecting: Error state for start');
        return [
          isA<ParkingState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Start failed'),
          ),
        ];
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'StopParkingEvent failure → emits error state',
      build: () {
        when(
          () => mockRepo.stopParking(any(), any(), any()),
        ).thenThrow(Exception('Stop failed'));
        return bloc;
      },
      act: (bloc) {
        print('Sending event: StopParkingEvent');
        bloc.add(StopParkingEvent(1, {'parking': 'XYZ'}, 'test'));
      },
      expect: () {
        print('Expecting: Error state for stop');
        return [
          isA<ParkingState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Stop failed'),
          ),
        ];
      },
    );
  });
}
