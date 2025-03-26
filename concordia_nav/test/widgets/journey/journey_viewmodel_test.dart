import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concordia_floor_point.dart';
import 'package:concordia_nav/data/domain-model/concordia_room.dart';
import 'package:concordia_nav/data/domain-model/location.dart';
import 'package:concordia_nav/data/domain-model/navigation_decision.dart';
import 'package:concordia_nav/data/domain-model/room_category.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:concordia_nav/data/repositories/navigation_decision_repository.dart';
import 'package:concordia_nav/utils/journey/journey_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockNavigationDecisionRepository extends Mock
    implements NavigationDecisionRepository {}

void main() {
  late MockNavigationDecisionRepository mockRepository;
  late List<Location> journeyItems;
  late NavigationDecision mockDecision;

  setUp(() {
    mockRepository = MockNavigationDecisionRepository();
    journeyItems = [
      const Location(100, 100, "Mock location", null, null, null, null),
      const Location(100, 100, "Mock location", null, null, null, null)
    ];
    mockDecision = NavigationDecision(
        navCase: NavigationCase.multiStepJourney, pageSequence: ["O", "O"]);
  });

  test('should create ViewModel with a valid journey and initial decision', () {
    final viewModel = NavigationJourneyViewModel(
      repository: mockRepository,
      journeyItems: journeyItems,
    );

    expect(viewModel.decision.pageCount, 1);
  });

  test(
      'should determine navigation decision when no initial decision is provided',
      () {
    journeyItems = [
      ConcordiaRoom(
          'H-801',
          RoomCategory.classroom,
          ConcordiaFloor("1", BuildingRepository.h),
          ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
      ConcordiaRoom(
          'H-805',
          RoomCategory.classroom,
          ConcordiaFloor("1", BuildingRepository.h),
          ConcordiaFloorPoint(ConcordiaFloor("1", BuildingRepository.h), 0, 0)),
    ];

    final viewModel = NavigationJourneyViewModel(
      repository: mockRepository,
      journeyItems: journeyItems,
    );

    expect(viewModel.decision.navCase, equals(mockDecision.navCase));
  });

  test('should throw an exception if journeyItems has less than 2 locations',
      () {
    mockDecision = NavigationDecision(
        navCase: NavigationCase.multiStepJourney, pageSequence: ["O"]);

    expect(
      () => NavigationJourneyViewModel(
        repository: mockRepository,
        journeyItems: [
          const Location(100, 100, "Mock location", null, null, null, null)
        ],
      ),
      throwsException,
    );
  });

  test('should throw an exception if navigation decision cannot be determined',
      () {
    journeyItems = [];
    expect(
      () => NavigationJourneyViewModel(
        repository: mockRepository,
        journeyItems: journeyItems,
      ),
      throwsException,
    );
  });
}
