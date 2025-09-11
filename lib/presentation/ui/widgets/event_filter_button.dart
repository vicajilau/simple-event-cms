import 'package:flutter/material.dart';

enum EventFilter {
  all('All'),
  past('Past Events'),
  current('Current Events');

  const EventFilter(this.label);
  final String label;
}

class EventFilterButton extends StatelessWidget {
  final EventFilter selectedFilter;
  final ValueChanged<EventFilter> onFilterChanged;

  const EventFilterButton({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<EventFilter>(
      icon: Icon(
        Icons.filter_list,
        color: Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'Filtrar eventos',
      onSelected: onFilterChanged,
      itemBuilder: (BuildContext context) {
        return EventFilter.values.map((EventFilter filter) {
          return PopupMenuItem<EventFilter>(
            value: filter,
            child: Row(
              children: [
                Icon(
                  selectedFilter == filter
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(filter.label),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
