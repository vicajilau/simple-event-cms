import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/organization/organization_viewmodel.dart';
import 'package:sec/presentation/ui/widgets/form_screen_wrapper.dart';
import 'package:sec/presentation/ui/widgets/section_input_form.dart';

import '../../../../core/utils/app_decorations.dart';
import '../../../../core/utils/app_fonts.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _organizationNameController;
  late TextEditingController _primaryColorOrganizationController;
  late TextEditingController _secondaryColorOrganizationController;
  late TextEditingController _githubUserController;
  late TextEditingController _projectNameController;
  late TextEditingController _branchController;

  final _viewModel = getIt<OrganizationViewModel>();
  final organization = getIt<Organization>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings
    _organizationNameController =
        TextEditingController(text: organization.organizationName);
    _primaryColorOrganizationController =
        TextEditingController(text: organization.primaryColorOrganization);
    _secondaryColorOrganizationController =
        TextEditingController(text: organization.secondaryColorOrganization);
    _githubUserController = TextEditingController(text: organization.githubUser);
    _projectNameController = TextEditingController(text: organization.projectName);
    _branchController = TextEditingController(text: organization.branch);
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _primaryColorOrganizationController.dispose();
    _secondaryColorOrganizationController.dispose();
    _githubUserController.dispose();
    _projectNameController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = AppLocalizations.of(context)!;
    return FormScreenWrapper(
      pageTitle: location.organization,
      widgetFormChild: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              location.organization,
              style: AppFonts.titleHeadingForm.copyWith(color: Colors.blue),
            ),
            SectionInputForm(
              label: location.organizationName,
              childInput: TextFormField(
                controller: _organizationNameController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: location.organizationNameHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return location.requiredField;
                  }
                  return null;
                },
              ),
            ),
            SectionInputForm(
              label: location.primaryColorLabel,
              childInput: TextFormField(
                controller: _primaryColorOrganizationController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: location.primaryColorHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return location.requiredField;
                  }
                  return null;
                },
              ),
            ),
            SectionInputForm(
              label: location.secondaryColorLabel,
              childInput: TextFormField(
                controller: _secondaryColorOrganizationController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: location.secondaryColorHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return location.requiredField;
                  }
                  return null;
                },
              ),
            ),
            SectionInputForm(
              label: location.githubUser,
              childInput: TextFormField(
                controller: _githubUserController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: location.githubUserHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return location.requiredField;
                  }
                  return null;
                },
              ),
            ),
            SectionInputForm(
              label: location.projectNameLabel,
              childInput: TextFormField(
                controller: _projectNameController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: location.projectNameHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return location.requiredField;
                  }
                  return null;
                },
              ),
            ),
            SectionInputForm(
              label: location.branch,
              childInput: TextFormField(
                controller: _branchController,
                decoration: AppDecorations.textFieldDecoration.copyWith(
                  hintText: location.branchHint,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return location.requiredField;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(location.cancelButton),
                ),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final organization = Organization(
                        organizationName: _organizationNameController.text,
                        primaryColorOrganization:
                            _primaryColorOrganizationController.text,
                        secondaryColorOrganization:
                            _secondaryColorOrganizationController.text,
                        githubUser: _githubUserController.text,
                        projectName: _projectNameController.text,
                        branch: _branchController.text,
                      );
                      _viewModel.updateOrganization(organization, context);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(location.saveButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
