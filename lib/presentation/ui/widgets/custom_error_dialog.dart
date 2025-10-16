import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const CustomErrorDialog({
    Key? key,
    required this.errorMessage,
    this.onRetry,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(errorMessage),
      actions: <Widget>[
        if (onCancel != null)
          TextButton(
            child: const Text('Cancelar'),
            onPressed: onCancel,
          ),
        if (onRetry != null)
          TextButton(
            child: const Text('Reintentar'),
            onPressed: onRetry,
          ),
      ],
    );
  }
}
