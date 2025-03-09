import 'package:concordia_nav/data/domain-model/concordia_floor.dart';
import 'package:concordia_nav/data/domain-model/concrete_floor_routable_point.dart';
import 'package:concordia_nav/data/repositories/building_repository.dart';
import 'package:test/test.dart';

void main() {
  group('ConcreteFloorRoutablePoint', () {
    test('should correctly initialize with constructor', () {
      // Arrange
      final ConcordiaFloor floor =
          ConcordiaFloor("1", BuildingRepository.h); // Mock or actual instance
      const double x = 5.0;
      const double y = 10.0;

      // Act
      final point =
          ConcreteFloorRoutablePoint(floor: floor, positionX: x, positionY: y);

      // Assert
      expect(point.floor, equals(floor));
      expect(point.positionX, equals(x));
      expect(point.positionY, equals(y));
    });

    test('should get and set floor correctly', () {
      // Arrange
      final ConcordiaFloor floor = ConcordiaFloor("1", BuildingRepository.h);
      final ConcordiaFloor newFloor =
          ConcordiaFloor("1", BuildingRepository.h); // Another floor instance
      const double x = 5.0;
      const double y = 10.0;

      final point =
          ConcreteFloorRoutablePoint(floor: floor, positionX: x, positionY: y);

      // Act
      point.floor = newFloor;

      // Assert
      expect(point.floor, equals(newFloor));
    });

    test('should get and set positionX correctly', () {
      // Arrange
      final ConcordiaFloor floor = ConcordiaFloor("1", BuildingRepository.h);
      const double initialX = 5.0;
      const double newX = 7.0;
      const double y = 10.0;

      final point = ConcreteFloorRoutablePoint(
          floor: floor, positionX: initialX, positionY: y);

      // Act
      point.positionX = newX;

      // Assert
      expect(point.positionX, equals(newX));
    });

    test('should get and set positionY correctly', () {
      // Arrange
      final ConcordiaFloor floor = ConcordiaFloor("1", BuildingRepository.h);
      const double x = 5.0;
      const double initialY = 10.0;
      const double newY = 15.0;

      final point = ConcreteFloorRoutablePoint(
          floor: floor, positionX: x, positionY: initialY);

      // Act
      point.positionY = newY;

      // Assert
      expect(point.positionY, equals(newY));
    });
  });
}
