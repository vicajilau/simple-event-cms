import 'package:flutter/material.dart';

class AddFloatingActionButton extends StatelessWidget {
  final void Function()? onPressed;

  const AddFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      elevation: 16,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: CircleBorder(),
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}
