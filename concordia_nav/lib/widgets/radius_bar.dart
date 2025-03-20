import 'package:flutter/material.dart';

class RadiusBar extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final ValueChanged<double> onRadiusChanged;

  const RadiusBar({
    super.key,
    this.initialValue = 50.0,
    this.minValue = 10.0,
    this.maxValue = 200.0,
    required this.onRadiusChanged,
  });

  @override
  State<RadiusBar> createState() => _RadiusBarState();
}

class _RadiusBarState extends State<RadiusBar> {
  late double _currentValue;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _textController = TextEditingController(text: _currentValue.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateValue(double value) {
    setState(() {
      _currentValue = value;
      _textController.text = value.toStringAsFixed(0);
    });
    widget.onRadiusChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            children: [
              const Text(
                'Search Radius:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                width: 60.0,
                height: 36.0,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    final newValue = double.tryParse(value);
                    if (newValue != null) {
                      final double clampedValue = newValue.clamp(widget.minValue, widget.maxValue);
                      _updateValue(clampedValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 4.0),
              const Text('m'),
            ],
          ),
          Row(
            children: [
              Text('${widget.minValue.toInt()}m'),
              Expanded(
                child: Slider(
                  value: _currentValue,
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: ((widget.maxValue - widget.minValue) / 5).round(),
                  activeColor: const Color.fromRGBO(146, 35, 56, 1),
                  onChanged: _updateValue,
                ),
              ),
              Text('${widget.maxValue.toInt()}m'),
            ],
          ),
        ],
      ),
    );
  }
}