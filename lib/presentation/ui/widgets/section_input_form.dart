import 'package:flutter/material.dart';

import '../../../core/utils/app_fonts.dart';

class SectionInputForm extends StatelessWidget {
  final String label;
  final Widget childInput;

  const SectionInputForm({
    super.key,
    required this.label,
    required this.childInput,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.labelMediumForm.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        childInput,
      ],
    );
  }
}
