import 'package:flutter/material.dart';
import 'package:sec/core/di/config_dependency_helper.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/core/routing/check_org.dart';
import 'package:sec/l10n/app_localizations.dart';
import 'package:sec/presentation/ui/screens/config/config_viewmodel.dart';
import 'package:sec/presentation/ui/widgets/custom_error_dialog.dart';
import 'package:sec/presentation/ui/widgets/form_screen_wrapper.dart';
import 'package:sec/presentation/ui/widgets/section_input_form.dart';
import 'package:sec/presentation/view_model_common.dart';

import '../../../../core/utils/app_decorations.dart';
import '../../../../core/utils/app_fonts.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late TextEditingController _configNameController;
  late TextEditingController _primaryColorOrganizationController;
  late TextEditingController _secondaryColorOrganizationController;
  late TextEditingController _githubUserController;
  late TextEditingController _projectNameController;
  late TextEditingController _branchController;

  final viewModel = getIt<ConfigViewModel>();
  final config = getIt<Config>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings
    _configNameController = TextEditingController(text: config.configName);
    _primaryColorOrganizationController = TextEditingController(
      text: config.primaryColorOrganization,
    );
    _secondaryColorOrganizationController = TextEditingController(
      text: config.secondaryColorOrganization,
    );
    _githubUserController = TextEditingController(text: config.githubUser);
    _projectNameController = TextEditingController(text: config.projectName);
    _branchController = TextEditingController(text: config.branch);
  }

  @override
  void dispose() {
    _configNameController.dispose();
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
    final orgHealth = getIt<CheckOrg>();
    final bool hideCancel = orgHealth.hasError;

    return ValueListenableBuilder<ViewState>(
      valueListenable: viewModel.viewState,
      builder: (context, viewState, _) {
        if (viewState == ViewState.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => CustomErrorDialog(
                errorMessage: viewModel.errorMessage,
                onCancel: () => {Navigator.of(context).pop()},
                buttonText: location.closeButton,
              ),
            );
          });
        }

        return FormScreenWrapper(
          pageTitle: location.config,
          widgetFormChild: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  location.config,
                  style: AppFonts.titleHeadingForm.copyWith(color: Colors.blue),
                ),
                SectionInputForm(
                  label: location.configName,
                  childInput: TextFormField(
                    controller: _configNameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: AppDecorations.textFieldDecoration.copyWith(
                      hintText: location.configNameHint,
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,

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
                    autovalidateMode: AutovalidateMode.onUserInteraction,

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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    if (!hideCancel) // only when there is NO error
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(location.cancelButton),
                      ),
                    FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final updated = Config(
                            configName: _configNameController.text,
                            primaryColorOrganization:
                                _primaryColorOrganizationController.text,
                            secondaryColorOrganization:
                                _secondaryColorOrganizationController.text,
                            githubUser: _githubUserController.text,
                            projectName: _projectNameController.text,
                            branch: _branchController.text,
                          );

                          final ok = await viewModel.updateConfig(updated);

                          if (ok) {
                            setOrganization(updated);
                            getIt<CheckOrg>().setError(false);
                            if (context.mounted) {
                              Navigator.of(context).pop<Config>(updated);
                            }
                          }
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
      },
    );
  }
}
