import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application/bloc/parkingplace/parking_space_bloc.dart';
import 'package:flutter_application/bloc/parkingplace/parking_space_event.dart';
import 'package:flutter_application/bloc/parkingplace/parking_space_state.dart';

import '../repository/mock_parking_space_repository.dart';

void main() {
  late ParkingPlaceBloc bloc;
  late MockParkingSpaceRepository mockRepo;

  setUp(() {
    mockRepo = MockParkingSpaceRepository();
    bloc = ParkingPlaceBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  group('ParkingPlaceBloc', () {
    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits [Loading, Loaded] when LoadParkingSpacesEvent succeeds',
      build: () {
        when(() => mockRepo.getAll()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpacesEvent()),
      expect:
          () => [
            isA<ParkingPlaceLoadingState>(),
            isA<ParkingPlaceLoadedState>().having(
              (s) => s.spaces,
              'spaces',
              [],
            ),
          ],
    );

    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits [Loading, Error] when LoadParkingSpacesEvent fails',
      build: () {
        when(() => mockRepo.getAll()).thenThrow(Exception('Load failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpacesEvent()),
      expect:
          () => [
            isA<ParkingPlaceLoadingState>(),
            isA<ParkingPlaceErrorState>().having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Load failed'),
            ),
          ],
    );

    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits [Loaded] after AddParkingSpaceEvent succeeds',
      build: () {
        when(() => mockRepo.add(any())).thenAnswer((_) async => {});
        when(() => mockRepo.getAll()).thenAnswer(
          (_) async => [
            {'id': '23232', 'address': 'Street 1', 'pricePerHour': 10.0},
          ],
        );
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            AddParkingSpaceEvent({
              'address': 'Street 1',
              'pricePerHour': 10.0,
            }, 'test-uid'),
          ),
      expect:
          () => [
            isA<ParkingPlaceLoadedState>().having((s) => s.spaces, 'spaces', [
              {'id': '23232', 'address': 'Street 1', 'pricePerHour': 10.0},
            ]),
          ],
    );

    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits [Loaded] after DeleteParkingSpaceEvent succeeds',
      build: () {
        when(() => mockRepo.delete(any())).thenAnswer((_) async {});
        when(() => mockRepo.getAll()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteParkingSpaceEvent('2323', 'test-uid')),
      expect:
          () => [
            isA<ParkingPlaceLoadedState>().having(
              (s) => s.spaces,
              'spaces',
              [],
            ),
          ],
    );
  });
}
