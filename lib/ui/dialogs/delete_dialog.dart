import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String title, message;
  final void Function() onDeletePressed;
  const DeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Delete"),
          onPressed: () {
            Navigator.of(context).pop();
            onDeletePressed();
          },
        ),
      ],
    );
  }
}
