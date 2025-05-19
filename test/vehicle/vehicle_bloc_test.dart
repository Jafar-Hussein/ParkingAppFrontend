import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application/bloc/parking/parking_bloc.dart';
import 'package:flutter_application/bloc/parking/parking_event.dart';
import 'package:flutter_application/bloc/parking/parking_state.dart';

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
        when(
          () => mockRepo.getParkingHistory(any()),
        ).thenAnswer((_) async => []);
        when(() => mockRepo.getAvailableSpaces()).thenAnswer((_) async => []);
        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadParkingDataEvent('uid123')),
      expect:
          () => [
            isA<ParkingState>().having((s) => s.isLoading, 'isLoading', true),
            isA<ParkingState>()
                .having((s) => s.isLoading, 'isLoading', false)
                .having((s) => s.parkingHistory, 'parkingHistory', [])
                .having((s) => s.availableSpaces, 'availableSpaces', [])
                .having((s) => s.vehicles, 'vehicles', []),
          ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'LoadParkingDataEvent failure → emits error state',
      build: () {
        when(
          () => mockRepo.getParkingHistory(any()),
        ).thenThrow(Exception('Failed'));
        when(() => mockRepo.getAvailableSpaces()).thenAnswer((_) async => []);
        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadParkingDataEvent('uid123')),
      expect:
          () => [
            isA<ParkingState>().having((s) => s.isLoading, 'isLoading', true),
            isA<ParkingState>()
                .having((s) => s.isLoading, 'isLoading', false)
                .having(
                  (s) => s.errorMessage,
                  'errorMessage',
                  contains('Failed'),
                ),
          ],
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
        bloc.add(
          StartParkingEvent('spaceId1', {'vehicle': 'ABC123'}, 'uid123', 'adress111'),
        );
      },
      expect:
          () => [
            isA<ParkingState>().having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Start failed'),
            ),
          ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'StopParkingEvent failure → emits error state',
      build: () {
        when(
          () => mockRepo.stopParking(any(), any()),
        ).thenThrow(Exception('Stop failed'));
        return bloc;
      },
      act: (bloc) {
        bloc.add(
          StopParkingEvent("123123124", {'parking': 'data'}, 'uid123', 'Alex'),
        );
      },
      expect:
          () => [
            isA<ParkingState>().having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Stop failed'),
            ),
          ],
    );
  });
}
