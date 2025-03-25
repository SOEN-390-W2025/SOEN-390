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
  late Color _primaryTextColor;
  late Color _secondaryTextColor;
  late Color _cardColor;

  // Create a preview theme
  late ThemeData _previewTheme;

  @override
  void initState() {
    super.initState();
    // Get current theme colors
    _primaryColor = AppTheme.theme.primaryColor;
    _secondaryColor = AppTheme.theme.colorScheme.secondary;
    _backgroundColor = AppTheme.theme.scaffoldBackgroundColor;
    _primaryTextColor = AppTheme.theme.textTheme.bodyLarge?.color ?? Colors.black;
    _secondaryTextColor = AppTheme.theme.colorScheme.onPrimary;
    _cardColor = AppTheme.theme.cardColor;

    // Initialize preview theme
    _updatePreviewTheme();
  }

  // Update the preview theme with current color selections
  void _updatePreviewTheme() {
    _previewTheme = AppTheme.createTheme(
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      backgroundColor: _backgroundColor,
      primaryTextColor: _primaryTextColor,
      secondaryTextColor: _secondaryTextColor,
      cardColor: _cardColor,
    );
  }

  void _showColorWheel(Color currentColor, void Function(Color) onColorChanged, String colorName) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $colorName'),
          content: Semantics(
            label: 'Color picker for $colorName',
            hint: 'Use the color wheel to select a new color',
            child: SingleChildScrollView(
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
          ),
          actions: <Widget>[
            Semantics(
              button: true,
              label: 'Cancel color selection',
              child: TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Semantics(
              button: true,
              label: 'Apply selected color',
              child: ElevatedButton(
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
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateAppTheme() async {
    // Update the app's theme with current color selections
    await AppTheme.updateTheme(_previewTheme);
  }

  Future<void> _resetToDefault() async {
    await AppTheme.resetToDefault();
    setState(() {
      _primaryColor = AppTheme.theme.primaryColor;
      _secondaryColor = AppTheme.theme.colorScheme.secondary;
      _backgroundColor = AppTheme.theme.scaffoldBackgroundColor;
      _primaryTextColor = AppTheme.theme.textTheme.bodyLarge?.color ?? Colors.black;
      _secondaryTextColor = AppTheme.theme.colorScheme.onPrimary;
      _cardColor = AppTheme.theme.cardColor;
      _updatePreviewTheme();
    });
  }

  Widget _buildColorRow(String label, Color color, void Function(Color) onColorChanged) {
    return Semantics(
      label: '$label selection',
      hint: 'Tap to change $label',
      button: true,
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
                  color: _primaryTextColor,
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
    return Semantics(
      label: 'Theme preview section',
      hint: 'Shows how your selected colors will look in the app',
      child: Container(
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
                color: _primaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            // Preview card
            Semantics(
              label: 'Card preview',
              child: Card(
                color: _cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card Preview',
                        style: TextStyle(
                          color: _primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'This shows how cards will appear',
                        style: TextStyle(
                          color: _primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Preview primary button
            Semantics(
              label: 'Primary button preview',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _secondaryTextColor,
                ),
                onPressed: () {},
                child: const Text('Primary Button'),
              ),
            ),
            const SizedBox(height: 8),

            // Preview secondary button
            Semantics(
              label: 'Secondary button preview',
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _primaryColor),
                  foregroundColor: _primaryColor,
                ),
                onPressed: () {},
                child: const Text('Secondary Button'),
              ),
            ),

            // Preview icon
            const SizedBox(height: 12),
            Semantics(
              label: 'Icon preview',
              child: Row(
                children: [
                  Icon(Icons.favorite, color: _secondaryColor, semanticLabel: 'Secondary color icon'),
                  const SizedBox(width: 8),
                  Icon(Icons.notifications, color: _primaryColor, semanticLabel: 'Primary color icon'),
                ],
              ),
            ),
          ],
        ),
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
        body: Semantics(
          label: 'Color adjustment page',
          hint: 'Customize app colors and preview changes',
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customize your colors',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),

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
                    'Card color',
                    _cardColor,
                    (color) => setState(() => _cardColor = color)
                  ),
                  _buildColorRow(
                    'Primary text color',
                    _primaryTextColor,
                    (color) => setState(() => _primaryTextColor = color)
                  ),
                  _buildColorRow(
                    'Secondary text color',
                    _secondaryTextColor,
                    (color) => setState(() => _secondaryTextColor = color)
                  ),

                  const SizedBox(height: 24),

                  // Preview section
                  _buildPreviewSection(),

                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: 'Save theme changes',
                      hint: 'Applies the selected colors to your app',
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saving theme settings...'))
                          );

                          // Update app theme
                          await _updateAppTheme();

                          // Show success message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Theme updated successfully!'))
                            );
                          }
                        },
                        child: const Text(
                          'Save changes',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reset button
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: 'Reset to default theme',
                      hint: 'Restores the original app colors',
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).primaryColor),
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Resetting theme...'))
                          );

                          // Reset theme
                          await _resetToDefault();

                          // Show success message
                          if (context.mounted) {
                             ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Theme reset to default'))
                            );
                          }

                        },
                        child: const Text(
                          'Reset to default',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}