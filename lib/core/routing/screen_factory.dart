import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';
import '../../domain/use_cases/event_use_case.dart';

class ScreenFactory {
  const ScreenFactory();

  static EventCollectionScreen eventCollectionScreen() {
    return EventCollectionScreen(crossAxisCount: 4);
  }

  static EventDetailScreen eventDetailScreen(String eventId) {
    final useCase = getIt<EventUseCase>();
    final viewmodel = EventDetailViewModelImp(useCase);
    return EventDetailScreen(viewmodel: viewmodel, eventId: eventId);
  }
}
