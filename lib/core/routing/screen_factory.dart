import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

class ScreenFactory {
  const ScreenFactory();

  static EventCollectionScreen eventCollectionScreen() {
    return EventCollectionScreen(crossAxisCount: 4);
  }

  static EventDetailScreen eventDetailScreen(String eventId) {
    final viewmodel = EventDetailViewModelImp();
    return EventDetailScreen(viewmodel: viewmodel, eventId: eventId);
  }
}
