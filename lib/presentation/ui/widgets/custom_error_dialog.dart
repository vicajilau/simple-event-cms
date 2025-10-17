import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const CustomErrorDialog({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(errorMessage),
      actions: <Widget>[
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancelar'),
          ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
      ],
    );
  }
}
