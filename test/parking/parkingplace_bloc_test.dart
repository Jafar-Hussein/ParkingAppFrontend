import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application/bloc/parkingplace/parking_space_bloc.dart';
import 'package:flutter_application/bloc/parkingplace/parking_space_event.dart';
import 'package:flutter_application/bloc/parkingplace/parking_space_state.dart';
import 'package:flutter_application/repository/ParkingSpaceRepository.dart';

import '../repository/mock_parking_space_repository.dart';

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
      'emits [loading, loaded] on LoadParkingSpacesEvent',
      build: () {
        when(() => mockRepo.getAll()).thenAnswer((_) async {
          print('mockRepo.getAll() → returns []');
          return [];
        });
        return bloc;
      },
      act: (bloc) {
        print('Sending event: LoadParkingSpacesEvent');
        bloc.add(LoadParkingSpacesEvent());
      },
      expect: () {
        print('Expecting: Loading then Loaded (empty list)');
        return [
          isA<ParkingPlaceLoadingState>(),
          isA<ParkingPlaceLoadedState>().having((s) => s.spaces, 'spaces', []),
        ];
      },
    );

    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits error state on LoadParkingSpacesEvent failure',
      build: () {
        when(() => mockRepo.getAll()).thenThrow(Exception('Load failed'));
        return bloc;
      },
      act: (bloc) {
        print('Sending event: LoadParkingSpacesEvent (with failure)');
        bloc.add(LoadParkingSpacesEvent());
      },
      expect: () {
        print('Expecting: Loading then Error');
        return [
          isA<ParkingPlaceLoadingState>(),
          isA<ParkingPlaceErrorState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Load failed'),
          ),
        ];
      },
    );

    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits loaded state after successful AddParkingSpaceEvent',
      build: () {
        when(() => mockRepo.add(any())).thenAnswer((_) async {
          print('mockRepo.add() called');
        });
        when(() => mockRepo.getAll()).thenAnswer((_) async {
          print('mockRepo.getAll() → returns updated list');
          return [
            {'id': 1, 'address': 'Street 1', 'pricePerHour': 10.0},
          ];
        });
        return bloc;
      },
      act: (bloc) {
        print('Sending event: AddParkingSpaceEvent');
        bloc.add(
          AddParkingSpaceEvent({'address': 'Street 1', 'pricePerHour': 10.0}),
        );
      },
      expect: () {
        print('Expecting: Loaded state with new space');
        return [
          isA<ParkingPlaceLoadedState>().having(
            (s) => s.spaces.length,
            'spaces.length',
            1,
          ),
        ];
      },
    );

    blocTest<ParkingPlaceBloc, ParkingSpaceState>(
      'emits loaded state after successful DeleteParkingSpaceEvent',
      build: () {
        when(() => mockRepo.delete(any())).thenAnswer((_) async {
          print('mockRepo.delete() called with id');
        });
        when(() => mockRepo.getAll()).thenAnswer((_) async {
          print('mockRepo.getAll() → returns updated list after delete');
          return [];
        });
        return bloc;
      },
      act: (bloc) {
        print('Sending event: DeleteParkingSpaceEvent');
        bloc.add(DeleteParkingSpaceEvent(1));
      },
      expect: () {
        print('Expecting: Loaded state with updated list');
        return [
          isA<ParkingPlaceLoadedState>().having((s) => s.spaces, 'spaces', []),
        ];
      },
    );
  });
}
