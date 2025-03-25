import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../widgets/custom_appbar.dart';
import '../../themes/app_theme.dart';

class ColorAdjustmentView extends StatefulWidget {
  const ColorAdjustmentView({super.key});

  @override
  State<ColorAdjustmentView> createState() => _ColorAdjustmentViewState();
}

class _ColorAdjustmentViewState extends State<ColorAdjustmentView> {
  // Initialize with current theme colors
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _backgroundColor;
  late Color _textColor;

  // Create a preview theme
  late ThemeData _previewTheme;

  @override
  void initState() {
    super.initState();
    // Get current theme colors
    _primaryColor = AppTheme.theme.primaryColor;
    _secondaryColor = AppTheme.theme.colorScheme.secondary;
    _backgroundColor = AppTheme.theme.scaffoldBackgroundColor;
    _textColor = AppTheme.theme.textTheme.bodyLarge?.color ?? Colors.black;

    // Initialize preview theme
    _updatePreviewTheme();
  }

  // Update the preview theme with current color selections
  void _updatePreviewTheme() {
    _previewTheme = ThemeData(
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _backgroundColor,
      ),
      iconTheme: IconThemeData(
        color: _primaryColor,
      ),
      textTheme: AppTheme.theme.textTheme.apply(
        bodyColor: _textColor,
        displayColor: _textColor,
      ),
      // Ensure buttons and other components also use the selected colors
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showColorWheel(Color currentColor, void Function(Color) onColorChanged, String colorName) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $colorName'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                // Update the picker color while selecting
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              displayThumbColor: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('APPLY'),
              onPressed: () {
                // Apply the color change and update the preview
                onColorChanged(pickerColor);
                setState(() {
                  _updatePreviewTheme();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateAppTheme() {
    // Update the app's theme with current color selections
    AppTheme.updateTheme(_previewTheme);
  }

  void _resetToDefault() {
    AppTheme.resetToDefault();
    setState(() {
      _primaryColor = AppTheme.theme.primaryColor;
      _secondaryColor = AppTheme.theme.colorScheme.secondary;
      _backgroundColor = AppTheme.theme.scaffoldBackgroundColor;
      _textColor = AppTheme.theme.textTheme.bodyLarge?.color ?? Colors.black;
      _updatePreviewTheme();
    });
  }

  Widget _buildColorRow(String label, Color color, void Function(Color) onColorChanged) {
    return Semantics(
      label: '$label selection',
      hint: 'Tap to change $label',
      child: GestureDetector(
        onTap: () => _showColorWheel(color, onColorChanged, label),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Preview widgets to demonstrate the selected colors
  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Preview text
          Text(
            'This is how text will appear',
            style: TextStyle(
              color: _textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Preview primary button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text('Primary Button'),
          ),
          const SizedBox(height: 8),

          // Preview secondary button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _secondaryColor),
              foregroundColor: _secondaryColor,
            ),
            onPressed: () {},
            child: const Text('Secondary Button'),
          ),

          // Preview icon
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite, color: _secondaryColor),
              const SizedBox(width: 8),
              Icon(Icons.notifications, color: _primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the entire UI with the preview theme colors
    return Theme(
      data: AppTheme.theme,
      child: Scaffold(
        appBar: customAppBar(context, 'Color Adjustment'),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customize your colors',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Color selection rows
              _buildColorRow(
                'Primary color',
                _primaryColor,
                (color) => setState(() => _primaryColor = color)
              ),
              _buildColorRow(
                'Secondary color',
                _secondaryColor,
                (color) => setState(() => _secondaryColor = color)
              ),
              _buildColorRow(
                'Background color',
                _backgroundColor,
                (color) => setState(() => _backgroundColor = color)
              ),
              _buildColorRow(
                'Text color',
                _textColor,
                (color) => setState(() => _textColor = color)
              ),

              const SizedBox(height: 24),

              // Preview section
              _buildPreviewSection(),

              const Spacer(),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _updateAppTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme updated successfully!'))
                    );
                  },
                  child: const Text(
                    'Save changes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _resetToDefault,
                  child: const Text(
                    'Reset to default',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}