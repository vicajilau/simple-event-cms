import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String errorMessage;
  final String buttonText;
  final VoidCallback? onCancel;

  const CustomErrorDialog({
    super.key,
    required this.errorMessage,
    required this.buttonText,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(errorMessage),
      actions: <Widget>[
        if (onCancel != null)
          TextButton(onPressed: onCancel, child: Text(buttonText)),
      ],
    );
  }
}
