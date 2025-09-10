import 'package:flutter/material.dart';

abstract class AppDecorations {
  static final InputDecoration textFieldDecoration = InputDecoration(
    /* hintText: hintText,*/
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.circular(8.0),
    ),
  );
}
