// event_controller_extension.dart
import 'package:calendar_view/calendar_view.dart';

extension EventControllerExtension on EventController {
  // Add clearAll method if it's not already available in the library
  void clearAll() {
    // This assumes the EventController has a removeWhere method as shown in your code
    removeWhere((_) => true);
  }
}