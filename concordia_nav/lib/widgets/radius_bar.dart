import 'package:flutter/material.dart';

class RadiusBar extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onRadiusChanged;
  final Function(double)? onRadiusChangeEnd;
  final bool showMeters;
  final Widget? travelModeSelector;

  const RadiusBar({
    super.key,
    this.initialValue = 50.0,
    this.minValue = 10.0,
    this.maxValue = 200.0,
    required this.onRadiusChanged,
    this.onRadiusChangeEnd,
    this.showMeters = true,
    this.travelModeSelector,
  });

  @override
  State<RadiusBar> createState() => _RadiusBarState();
}

class _RadiusBarState extends State<RadiusBar> {
  late double _currentValue;
  late TextEditingController _textController;
  late int _actualDivisions;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _textController = TextEditingController(text: _formatValue(_currentValue));
    _calculateDivisions();
  }

  void _calculateDivisions() {
    // Auto-calculate divisions based on the range
    final range = widget.maxValue - widget.minValue;
    if (range <= 100) {
      _actualDivisions = range.toInt();
    } else if (range <= 500) {
      _actualDivisions = (range / 5).round();
    } else {
      _actualDivisions = (range / 25).round();
    }
  }

  String _formatValue(double value) {
    // For values like 500, 1000, 1500, 2000, show as km
    if (!widget.showMeters && value >= 500 && value % 500 == 0) {
      return (value / 1000).toStringAsFixed(1);
    }
    return value.toInt().toString();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateValue(double value) {
    setState(() {
      _currentValue = value;
      _textController.text = _formatValue(value);
    });
    widget.onRadiusChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final String unitLabel = !widget.showMeters && _currentValue >= 500 ? 'km' : 'm';
    final String minLabel = widget.showMeters
        ? '${widget.minValue.toInt()}m'
        : widget.minValue >= 1000
            ? '${(widget.minValue / 1000).toStringAsFixed(1)}km'
            : '${widget.minValue.toInt()}m';
    final String maxLabel = widget.showMeters
        ? '${widget.maxValue.toInt()}m'
        : widget.maxValue >= 1000
            ? '${(widget.maxValue / 1000).toStringAsFixed(1)}km'
            : '${widget.maxValue.toInt()}m';

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Search radius label with icon
              Row(
                children: [
                  Icon(
                    Icons.radar,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6.0),
                  const Text(
                    'Search Radius:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Value input
                  Container(
                    width: 60.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 13.0,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (value) {
                              double? newValue = double.tryParse(value);
                              if (newValue != null && !widget.showMeters && unitLabel == 'km') {
                                newValue = newValue * 1000;
                              }
                              if (newValue != null) {
                                final double clampedValue = newValue.clamp(widget.minValue, widget.maxValue);
                                _updateValue(clampedValue);
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(
                            unitLabel,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Right side: Travel mode selector if provided
              if (widget.travelModeSelector != null)
                widget.travelModeSelector!,
            ],
          ),
          const SizedBox(height: 4.0),
          // Slider with labels
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.0,
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 8.0,
                elevation: 2.0,
              ),
              overlayColor: Theme.of(context).primaryColor.withAlpha(25),
              valueIndicatorColor: Theme.of(context).primaryColor,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
              tickMarkShape: SliderTickMarkShape.noTickMark,
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Column(
              children: [
                Slider(
                  value: _currentValue,
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: _actualDivisions,
                  label: '$_currentValue$unitLabel',
                  onChanged: _updateValue,
                  onChangeEnd: widget.onRadiusChangeEnd,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        minLabel,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        maxLabel,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}