import 'package:flutter/material.dart';

class FilterCheckbox extends StatefulWidget {
  final String label;
  final bool isChecked;
  final void Function(bool) onChanged;
  const FilterCheckbox({
    super.key,
    required this.isChecked,
    required this.label,
    required this.onChanged,
  });

  @override
  State<FilterCheckbox> createState() => _FilterCheckboxState();
}

class _FilterCheckboxState extends State<FilterCheckbox> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.label),
        Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
              widget.onChanged(value);
            });
          },
        ),
      ],
    );
  }
}
