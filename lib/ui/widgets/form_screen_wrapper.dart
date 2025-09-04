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
                  colors: [
                    Color.fromARGB(125, 9, 59, 109),
                    Color.fromARGB(255, 169, 208, 247),
                    Color.fromARGB(255, 9, 59, 109),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 550,
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
