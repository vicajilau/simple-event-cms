import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/ui/widgets/widgets.dart';

class SpeakerFormScreen extends StatefulWidget {
  const SpeakerFormScreen({super.key});

  @override
  State<SpeakerFormScreen> createState() => _SpeakerFormScreenState();
}

class _SpeakerFormScreenState extends State<SpeakerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FormScreenWrapper(
      pageTitle: AppLocalizations.of(context)?.speakerForm ?? '',
      widgetFormChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    AppLocalizations.of(context)?.speakerForm ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.nameLabel ?? '',
                childInput: TextFormField(
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)?.nameHint ?? '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.nameErrorHint ?? '';
                    }
                    return null;
                  },
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.imageUrlLabel ?? '',
                childInput: TextFormField(
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)?.imageUrlHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.bioLabel ?? '',
                childInput: TextFormField(
                  maxLines: 5,
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)?.bioHint ?? '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.bioErrorHint ?? '';
                    }
                    return null;
                  },
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.twitter ?? '',
                childInput: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.twitterHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.github ?? '',
                childInput: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.githubHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.linkedin ?? '',
                childInput: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.linkedinHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.website ?? '',
                childInput: TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.websiteHint ?? '',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(AppLocalizations.of(context)?.saveButton ?? ''),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
