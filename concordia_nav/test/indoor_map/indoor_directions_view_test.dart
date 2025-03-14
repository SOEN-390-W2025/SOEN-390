import 'package:concordia_nav/ui/indoor_location/indoor_directions_view.dart';
import 'package:concordia_nav/utils/indoor_directions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');

  const String yourLocationString = 'Your Location';

  late Widget view;
  late IndoorDirectionsViewModel mockDirectionsViewModel;

  setUp(() {
    mockDirectionsViewModel = IndoorDirectionsViewModel();
  });

  group('IndoorDirectionsView', () {
    testWidgets('handles previous floor press correctly',
        (WidgetTester tester) async {
      view = ChangeNotifierProvider<IndoorDirectionsViewModel>(
        create: (_) => mockDirectionsViewModel,
        child: MaterialApp(
          home: IndoorDirectionsView(
            sourceRoom: 'H 921',
            building: 'Hall Building',
            endRoom: 'H 830',
          ),
        ),
      );

      await tester.pumpWidget(view);

      final state = tester
          .state<IndoorDirectionsViewState>(find.byType(IndoorDirectionsView));

      state.handleNextFloorPress();
      await tester.pump();

      expect(state.widget.sourceRoom, 'H 921');
      expect(state.widget.endRoom, yourLocationString);
      expect(IndoorDirectionsViewState.isMultiFloor, true);

      state.handlePrevFloorPress();
      await tester.pump();

      expect(state.widget.sourceRoom, yourLocationString);
      expect(state.widget.endRoom, 'H 830');
      expect(IndoorDirectionsViewState.isMultiFloor, true);
    });

    testWidgets('IndoorDirectionsView renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IndoorDirectionsView(
            sourceRoom: yourLocationString,
            building: 'Hall Building',
            endRoom: 'H 110',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Indoor Directions'), findsOneWidget);
      expect(find.text('From: Your Location'), findsOneWidget);
      expect(find.textContaining('To: H 110'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('Start button exists and can be tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IndoorDirectionsView(
            sourceRoom: yourLocationString,
            building: 'Hall Building',
            endRoom: 'H110',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder startButton = find.text('Start');
      expect(startButton, findsOneWidget);

      await tester.tap(startButton);
      await tester.pumpAndSettle();

      expect(find.text('Step-by-Step Guide'), findsOneWidget);
    });
  });
}
