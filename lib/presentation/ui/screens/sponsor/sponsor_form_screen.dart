import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/utils/app_decorations.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

class SponsorFormScreen extends StatefulWidget {
  final Sponsor? sponsor;
  final String? eventUID;
  const SponsorFormScreen({super.key, this.sponsor, required this.eventUID});

  @override
  State<SponsorFormScreen> createState() => _SponsorFormScreenState();
}

class _SponsorFormScreenState extends State<SponsorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _logoController;
  late final TextEditingController _websiteController;
  late String _selectedCategory;

  final List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sponsor?.name ?? '');
    _logoController = TextEditingController(text: widget.sponsor?.logo ?? '');
    _websiteController = TextEditingController(
      text: widget.sponsor?.website ?? '',
    );
    _selectedCategory = widget.sponsor?.type ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = AppLocalizations.of(context)!;
    _categories.addAll([
      location.mainSponsor,
      location.goldSponsor,
      location.silverSponsor,
      location.bronzeSponsor,
    ]);
    if (_selectedCategory.isEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    final isEditing = widget.sponsor != null;

    return FormScreenWrapper(
      pageTitle: isEditing
          ? location.editSponsorTitle
          : location.createSponsorTitle,
      widgetFormChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                isEditing ? location.editingSponsor : location.creatingSponsor,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: const Color(0xFF38B6FF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SectionInputForm(
                label: location.nameLabel,
                childInput: TextFormField(
                  controller: _nameController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: location.sponsorNameHint,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? location.sponsorNameValidation
                      : null,
                ),
              ),

              SectionInputForm(
                label: location.logoLabel,
                childInput: TextFormField(
                  maxLines: 1,
                  controller: _logoController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: location.logoHint,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? location.logoValidation
                      : null,
                ),
              ),

              SectionInputForm(
                label: location.websiteLabel,
                childInput: TextFormField(
                  maxLines: 1,
                  controller: _websiteController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: location.websiteHint,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? location.websiteValidation
                      : null,
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xFF38B6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final sponsor = Sponsor(
                          uid:
                              widget.sponsor?.uid ??
                              'Sponsor_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
                          name: _nameController.text,
                          type: _selectedCategory,
                          logo: _logoController.text,
                          website: _websiteController.text,
                          eventUID: widget.eventUID.toString(),
                        );
                        if (context.mounted) {
                          context.pop<Sponsor>(sponsor);
                        }
                      }
                    },
                    child: Text(
                      isEditing ? location.updateButton : location.saveButton,
                    ),
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
