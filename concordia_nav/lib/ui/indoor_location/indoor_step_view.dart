// ignore_for_file: prefer_const_declarations

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

  const VirtualStepGuideView({
    super.key,
    required this.sourceRoom,
    required this.building,
    required this.floor,
    required this.endRoom,
    this.isDisability = false,
  });

  @override
  State<VirtualStepGuideView> createState() => _VirtualStepGuideViewState();
}

class _VirtualStepGuideViewState extends State<VirtualStepGuideView> 
    with TickerProviderStateMixin{
  late VirtualStepGuideViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VirtualStepGuideViewModel(
      sourceRoom: widget.sourceRoom,
      building: widget.building,
      floor: widget.floor,
      endRoom: widget.endRoom,
      isDisability: widget.isDisability,
      vsync: this,
    );
    
    _viewModel.initializeRoute().then((_) {
      // Add a slight delay to ensure the UI has been laid out
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _viewModel.focusOnCurrentStep(context);
        }
      });
    });
  }

  @override
  void dispose() {
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

  Widget _buildGuidanceBox(VirtualStepGuideViewModel viewModel) {
    if (viewModel.navigationSteps.isEmpty) {
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

    final currentStep = viewModel.navigationSteps[viewModel.currentStepIndex];

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
          // Navigation controls moved here
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: viewModel.currentStepIndex > 0 
                    ? () => viewModel.previousStep(context) 
                    : null,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                label: const Text('Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
              ),
              Text(
                '${viewModel.currentStepIndex + 1}/${viewModel.navigationSteps.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: viewModel.currentStepIndex < viewModel.navigationSteps.length - 1 
                    ? () => viewModel.nextStep(context) 
                    : () {
                        Navigator.pop(context);
                      },
                icon: Icon(viewModel.currentStepIndex < viewModel.navigationSteps.length - 1 
                    ? Icons.arrow_forward
                    : Icons.check,
                    color: Colors.white
                ),
                label: Text(viewModel.currentStepIndex < viewModel.navigationSteps.length - 1 
                    ? 'Next' 
                    : 'Finish'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
            semanticsLabel: 'Floor plan of ${viewModel.buildingAbbreviation}-${widget.floor}',
            width: viewModel.width,
            height: viewModel.height,
            highlightCurrentStep: true,
            currentStepPoint: viewModel.navigationSteps.isNotEmpty 
                ? viewModel.navigationSteps[viewModel.currentStepIndex].focusPoint 
                : null,
            showStepView: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTravelInfoBox(VirtualStepGuideViewModel viewModel) {
    // Calculate estimated remaining time (this assumes your viewModel has this data)
    final int estimatedRemainingMinutes = 20;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Time to destination',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$estimatedRemainingMinutes min',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
}