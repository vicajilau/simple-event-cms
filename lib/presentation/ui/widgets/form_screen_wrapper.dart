import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FormScreenWrapper extends StatelessWidget {
  final Widget widgetFormChild;
  final String pageTitle;

  const FormScreenWrapper({
    super.key,
    required this.widgetFormChild,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: Text(pageTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      body: kIsWeb
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB8E3FF), Color(0xFF38B6FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                    maxHeight: 850,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(32.0),
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(
                      scrollbars: false,
                    ),
                    child: SingleChildScrollView(child: widgetFormChild),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: widgetFormChild,
            ),
    );
  }
}
