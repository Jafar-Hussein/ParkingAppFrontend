import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_bloc.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_event.dart';
import 'package:flutter_application/bloc/vehicle/vehicle_state.dart';
import 'package:flutter_application/repository/vehicleRepository.dart';
import 'package:flutter_application/model/VehicleModel.dart';

import '../repository/mock_vehicle_repository.dart';

void main() {
  late VehicleBloc bloc;
  late MockVehicleRepository mockRepo;

  setUp(() {
    mockRepo = MockVehicleRepository();
    bloc = VehicleBloc(mockRepo);
  });

  tearDown(() => bloc.close());

  group('VehicleBloc', () {
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoadingState, VehicleLoadedState] on LoadVehiclesEvent',
      build: () {
        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async {
          print('getVehicles called with ownerName = "test" → returns []');
          return [];
        });
        return bloc;
      },
      act: (bloc) {
        print('Sending event: LoadVehiclesEvent("test")');
        bloc.add(LoadVehiclesEvent('test'));
      },
      expect: () {
        print('Expecting: VehicleLoadingState, VehicleLoadedState([])');
        return [
          isA<VehicleLoadingState>(),
          isA<VehicleLoadedState>().having((s) => s.vehicles, 'vehicles', []),
        ];
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleErrorState when LoadVehiclesEvent fails',
      build: () {
        when(() => mockRepo.getVehicles(any())).thenThrow(Exception('Failed'));
        return bloc;
      },
      act: (bloc) {
        print('Sending event: LoadVehiclesEvent("test") with failure');
        bloc.add(LoadVehiclesEvent('test'));
      },
      expect: () {
        print('Expecting: VehicleLoadingState, VehicleErrorState("Failed")');
        return [
          isA<VehicleLoadingState>(),
          isA<VehicleErrorState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Failed'),
          ),
        ];
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleLoadedState after successful AddVehicleEvent',
      build: () {
        when(() => mockRepo.addVehicle(any())).thenAnswer((_) async {
          print('addVehicle called');
        });

        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async {
          print('getVehicles called after add → returns 1 vehicle');
          return [
            VehicleModel(
              id: 1,
              registreringsnummer: 'ABC123',
              typ: 'Car',
              owner: 'Alex',
            ),
          ];
        });

        return bloc;
      },
      act: (bloc) {
        print('Sending event: AddVehicleEvent');
        bloc.add(
          AddVehicleEvent({
            'id': 1,
            'registreringsnummer': 'ABC123',
            'typ': 'Car',
            'owner': {'namn': 'Alex'},
          }),
        );
      },
      expect: () {
        print('Expecting: VehicleLoadedState with 1 vehicle');
        return [
          isA<VehicleLoadedState>().having(
            (s) => s.vehicles.length,
            'vehicles.length',
            1,
          ),
        ];
      },
    );
    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleLoadedState after successful DeleteVehicleEvent',
      build: () {
        when(() => mockRepo.deleteVehicle(any())).thenAnswer((_) async {
          print('deleteVehicle called with id 1');
        });
        when(() => mockRepo.getVehicles(any())).thenAnswer((_) async {
          print('getVehicles called after delete → returns []');
          return [];
        });
        return bloc;
      },
      act: (bloc) {
        print('Sending event: DeleteVehicleEvent');
        bloc.add(DeleteVehicleEvent(1, 'Alex'));
      },
      expect: () {
        print('Expecting: VehicleLoadedState with empty list');
        return [
          isA<VehicleLoadedState>().having((s) => s.vehicles, 'vehicles', []),
        ];
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleErrorState when AddVehicleEvent fails',
      build: () {
        when(
          () => mockRepo.addVehicle(any()),
        ).thenThrow(Exception('Add failed'));
        return bloc;
      },
      act: (bloc) {
        print('Sending event: AddVehicleEvent (with error)');
        bloc.add(
          AddVehicleEvent({
            'id': 1,
            'model': 'Car',
            'owner': {'namn': 'Alex'},
          }),
        );
      },
      expect: () {
        print('Expecting: VehicleErrorState("Add failed")');
        return [
          isA<VehicleErrorState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Add failed'),
          ),
        ];
      },
    );
  });
}
