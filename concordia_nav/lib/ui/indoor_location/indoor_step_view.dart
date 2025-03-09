// ignore_for_file: prefer_const_declarations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/indoor_step_viewmodel.dart';
import '../../widgets/custom_appbar.dart';
import 'floor_plan_widget.dart';

class VirtualStepGuideView extends StatefulWidget {
  final String building;
  final String floor;
  final String endRoom;
  final String sourceRoom;
  final bool isDisability;
  final bool isMultiFloor;
  final VirtualStepGuideViewModel? viewModel;

  const VirtualStepGuideView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.floor,
    required this.endRoom,
    required this.isMultiFloor,
    this.isDisability = false,
    this.viewModel,
  });

  @override
  State<VirtualStepGuideView> createState() => _VirtualStepGuideViewState();
}

class _VirtualStepGuideViewState extends State<VirtualStepGuideView>
    with TickerProviderStateMixin {
  late VirtualStepGuideViewModel _viewModel;
  bool _firstRouteCompleted = false;
  late String _temporaryEndRoom;
  late Timer _timer;

  late bool _isMultiFloorRoute;
  final String yourLocationString = 'Your Location';

  @override
  void initState() {
    super.initState();

    _isMultiFloorRoute = widget.isMultiFloor;
    _temporaryEndRoom = _isMultiFloorRoute ? 'connection' : widget.endRoom;

    _viewModel = widget.viewModel ??
        VirtualStepGuideViewModel(
          sourceRoom: widget.sourceRoom,
          building: widget.building,
          floor: widget.floor,
          endRoom: _temporaryEndRoom,
          isDisability: widget.isDisability,
          vsync: this,
        );

    _viewModel.initializeRoute().then((_) {
      if (mounted) {
        _timer = Timer(const Duration(milliseconds: 300), () {
          // ignore: use_build_context_synchronously
          _viewModel.focusOnCurrentStep(context);
        });
      }
    });
  }

  String extractFloor(String roomName) {
    if (roomName == yourLocationString) return '1';

    // Remove any building prefix if present (like "H " or "MB ")
    final cleanedRoom = roomName.replaceAll(RegExp(r'^[a-zA-Z]{1,2} '), '');

    // If the first character is alphabetic, get first two characters
    if (cleanedRoom.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(cleanedRoom)) {
      // For alphanumeric floors, take the first two characters
      return cleanedRoom.length >= 2
          ? cleanedRoom.substring(0, 2)
          : cleanedRoom;
    }
    // Otherwise if it starts with a digit, just get the first digit
    else if (cleanedRoom.isNotEmpty &&
        RegExp(r'^[0-9]').hasMatch(cleanedRoom)) {
      return cleanedRoom.substring(0, 1);
    }

    // Fallback
    return '1';
  }

  void _proceedToSecondRoute() {
    setState(() {
      _firstRouteCompleted = true;
      final String firstDigit =
          widget.endRoom.replaceAll(RegExp(r'\D'), '').isNotEmpty
              ? widget.endRoom.replaceAll(RegExp(r'\D'), '')[0]
              : widget.floor;
      _viewModel = VirtualStepGuideViewModel(
        sourceRoom: yourLocationString,
        building: widget.building,
        floor: firstDigit,
        endRoom: widget.endRoom,
        isDisability: widget.isDisability,
        vsync: this,
      );
      _viewModel.initializeRoute().then((_) {
        if (mounted) {
          _timer = Timer(const Duration(milliseconds: 300), () {
            // ignore: use_build_context_synchronously
            _viewModel.focusOnCurrentStep(context);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<VirtualStepGuideViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: customAppBar(context, 'Step-by-Step Guide'),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildGuidanceBox(viewModel),
                      _buildFloorPlanView(viewModel),
                      _buildTravelInfoBox(viewModel),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFloorPlanView(VirtualStepGuideViewModel viewModel) {
    return Expanded(
      child: Stack(
        children: [
          FloorPlanWidget(
            indoorMapViewModel: viewModel.indoorMapViewModel,
            floorPlanPath: viewModel.floorPlanPath,
            viewModel: viewModel.directionsViewModel,
            semanticsLabel:
                'Floor plan of ${viewModel.buildingAbbreviation}-${widget.floor}',
            width: viewModel.width,
            height: viewModel.height,
            highlightCurrentStep: true,
            currentStepPoint: viewModel.navigationSteps.isNotEmpty
                ? viewModel
                    .navigationSteps[viewModel.currentStepIndex].focusPoint
                : null,
            showStepView: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelInfoBox(VirtualStepGuideViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time estimate column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Time',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.getRemainingTimeEstimate(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Distance estimate column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Distance',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    viewModel.getRemainingDistanceEstimate(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Exit button
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            label: const Text('Exit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceBox(VirtualStepGuideViewModel viewModel) {
    if (viewModel.navigationSteps.isEmpty) {
      return _emptyGuidanceBox();
    }

    // Extract the final step condition and button logic
    final bool isFinalStep =
        viewModel.currentStepIndex >= viewModel.navigationSteps.length - 1;
    String buttonText;
    VoidCallback buttonOnPressed;

    if (isFinalStep && _isMultiFloorRoute && !_firstRouteCompleted) {
      buttonText = 'Continue';
      buttonOnPressed = _proceedToSecondRoute;
    } else if (isFinalStep) {
      buttonText = 'Finish';
      buttonOnPressed = () => Navigator.pop(context);
    } else {
      buttonText = 'Next';
      buttonOnPressed = () => viewModel.nextStep(context);
    }

    final currentStep = viewModel.navigationSteps[viewModel.currentStepIndex];

    // Update step titles and descriptions based on multi-floor route conditions
    if (_isMultiFloorRoute &&
        !_firstRouteCompleted &&
        currentStep.title == 'Destination') {
      final endFloor = extractFloor(widget.endRoom);
      currentStep.title = 'Connection';
      final transportMethod = widget.isDisability ? 'elevator' : 'escalators';
      currentStep.description = 'Take the $transportMethod to Floor $endFloor';
    }

    if (_isMultiFloorRoute &&
        _firstRouteCompleted &&
        currentStep.title == 'Start') {
      currentStep.title = 'Connection';
      final transportMethod = widget.isDisability ? 'elevator' : 'escalators';
      currentStep.description = 'Step out of the $transportMethod.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentStep.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStep.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStep.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button logic
              ElevatedButton(
                onPressed: () {
                  if (isFinalStep) {
                    Navigator.pop(context);
                  } else {
                    viewModel.previousStep(context);
                  }
                },
                child: const Text('Back'),
              ),
              Text(
                '${viewModel.currentStepIndex + 1}/${viewModel.navigationSteps.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Next/Finish/Continue button logic
              ElevatedButton(
                onPressed: buttonOnPressed,
                child: Text(buttonText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyGuidanceBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text("No navigation steps available"),
    );
  }
}
