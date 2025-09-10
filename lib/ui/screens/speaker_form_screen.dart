import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/models/speaker.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/ui/widgets/widgets.dart';

class SpeakerFormScreen extends StatefulWidget {
  final Speaker? speaker;
  const SpeakerFormScreen({super.key, this.speaker});

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
    final speaker = widget.speaker;
    if (speaker != null) {
      _nameController.text = speaker.name;
      _imageUrlController.text = speaker.image ?? '';
      _bioController.text = speaker.bio;
      _twitterController.text = speaker.social.twitter ?? '';
      _githubController.text = speaker.social.github ?? '';
      _linkedinController.text = speaker.social.linkedin ?? '';
      _websiteController.text = speaker.social.website ?? '';
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
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                          context,
                          Speaker(
                            uid:
                                widget.speaker?.uid ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            name: _nameController.text,
                            image: _imageUrlController.text,
                            bio: _bioController.text,
                            social: Social(
                              twitter: _twitterController.text,
                              github: _githubController.text,
                              linkedin: _linkedinController.text,
                              website: _websiteController.text,
                            ),
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
