import 'package:sec/presentation/ui/screens/screens.dart';

class ScreenFactory {
  const ScreenFactory();

  static EventCollectionScreen eventCollectionScreen() {
    return EventCollectionScreen(crossAxisCount: 4);
  }

  static EventDetailScreen eventDetailScreen(String eventId) {
    return EventDetailScreen(eventId: eventId);
  }
}
