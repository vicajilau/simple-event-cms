import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/presentation/ui/screens/event_collection/event_collection_view_model.dart';
import 'package:sec/presentation/ui/screens/event_detail/event_detail_view_model.dart';
import 'package:sec/presentation/ui/screens/screens.dart';

import '../../domain/use_cases/event_use_case.dart';
import '../models/models.dart';

class ScreenFactory {
  const ScreenFactory();

  static EventCollectionScreen eventCollectionScreen() {
    final useCase = getIt<EventUseCase>();
    final organization = getIt<Organization>();

    final viewmodel = EventCollectionViewModelImp(
      useCase: useCase,
      organization: organization,
    );
    return EventCollectionScreen(viewmodel: viewmodel, crossAxisCount: 4);
  }

  static EventDetailScreen eventDetailScreen(String eventId) {
    final useCase = getIt<EventUseCase>();
    final viewmodel = EventDetailViewModelImp(useCase, eventId);
    return EventDetailScreen(viewmodel: viewmodel, eventId: eventId);
  }
}
