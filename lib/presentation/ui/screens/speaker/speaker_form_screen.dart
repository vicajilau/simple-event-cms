import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/utils/app_decorations.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

class SpeakerFormScreen extends StatefulWidget {
  final Speaker? speaker;
  final String eventUID;
  const SpeakerFormScreen({super.key, this.speaker, required this.eventUID});

  @override
  State<SpeakerFormScreen> createState() => _SpeakerFormScreenState();
}

class _SpeakerFormScreenState extends State<SpeakerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _bioController = TextEditingController();
  final _twitterController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAndPopulateSpeakerData();
  }

  void _fetchAndPopulateSpeakerData() {
    if (mounted) {
      _nameController.text = widget.speaker?.name ?? '';
      _imageUrlController.text = widget.speaker?.image ?? '';
      _bioController.text = widget.speaker?.bio ?? '';
      _twitterController.text = widget.speaker?.social.twitter ?? '';
      _githubController.text = widget.speaker?.social.github ?? '';
      _linkedinController.text = widget.speaker?.social.linkedin ?? '';
      _websiteController.text = widget.speaker?.social.website ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _bioController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // You might want to use _speakerViewModel.viewState here to show loading/error states
    // For example, wrap the FormScreenWrapper or its child in a ValueListenableBuilder
    // listening to _speakerViewModel.viewState. For brevity, this example omits that.

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
                  controller: _nameController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
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
                  controller: _imageUrlController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: AppLocalizations.of(context)?.imageUrlHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.bioLabel ?? '',
                childInput: TextFormField(
                  controller: _bioController,
                  maxLines: 5,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
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
                  controller: _twitterController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.twitterHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.github ?? '',
                childInput: TextFormField(
                  controller: _githubController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.githubHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.linkedin ?? '',
                childInput: TextFormField(
                  controller: _linkedinController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: AppLocalizations.of(context)?.linkedinHint ?? '',
                  ),
                ),
              ),
              SectionInputForm(
                label: AppLocalizations.of(context)?.website ?? '',
                childInput: TextFormField(
                  controller: _websiteController,
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
                      if (_formKey.currentState!.validate() &&
                          context.mounted) {
                        Navigator.pop(
                          context,
                          Speaker(
                            uid:
                                widget.speaker?.uid ??
                                'Speaker_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
                            name: _nameController.text,
                            image: _imageUrlController.text,
                            bio: _bioController.text,
                            social: Social(
                              twitter: _twitterController.text,
                              github: _githubController.text,
                              linkedin: _linkedinController.text,
                              website: _websiteController.text,
                            ),
                            eventUID: widget.eventUID,
                          ),
                        );
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
