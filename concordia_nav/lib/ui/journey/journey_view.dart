import 'package:flutter/material.dart';
import '../../data/domain-model/location.dart';
import '../../data/domain-model/navigation_decision.dart';
import '../../data/repositories/navigation_decision_repository.dart';
import '../../utils/journey/journey_viewmodel.dart';
import '../../utils/map_viewmodel.dart';
import '../../widgets/journey/navigation_step_page.dart';

class NavigationJourneyPage extends StatefulWidget {
  final List<Location> journeyItems;
  final String journeyName;
  final MapViewModel? mapViewModel;
  final NavigationDecision? decision;

  const NavigationJourneyPage({
    super.key,
    required this.journeyItems,
    required this.journeyName,
    this.decision,
    this.mapViewModel,
  });

  @override
  State<NavigationJourneyPage> createState() => NavigationJourneyPageState();
}

class NavigationJourneyPageState extends State<NavigationJourneyPage> {
  late NavigationJourneyViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // A minimum (>= 2) number of Locations must be present within the List.
    if (widget.journeyItems.length < 2) {
      throw Exception("At least two journey items are required.");
    }
    viewModel = NavigationJourneyViewModel(
      repository: NavigationDecisionRepository(),
      journeyItems: widget.journeyItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationStepPage(
      journeyName: widget.journeyName,
      pageCount: viewModel.pages.length,
      pageBuilder: (i) => viewModel.pages[i],
    );
  }
}
