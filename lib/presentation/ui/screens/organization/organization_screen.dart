
import 'package:flutter/material.dart';
import 'package:sec/core/di/dependency_injection.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/presentation/ui/screens/organization/organization_viewmodel.dart';

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
  late TextEditingController _yearController;
  late TextEditingController _branchController;

  final _viewModel = getIt<OrganizationViewModel>();
  final organization = getIt<Organization>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings
    _organizationNameController = TextEditingController(text: organization.organizationName);
    _primaryColorOrganizationController = TextEditingController(text: organization.primaryColorOrganization);
    _secondaryColorOrganizationController = TextEditingController(text: organization.secondaryColorOrganization);
    _githubUserController = TextEditingController(text: organization.githubUser);
    _projectNameController = TextEditingController(text: organization.projectName);
    _yearController = TextEditingController(text: organization.year);
    _branchController = TextEditingController(text: organization.branch);
  }

  @override
  void dispose() {
    _organizationNameController.dispose();
    _primaryColorOrganizationController.dispose();
    _secondaryColorOrganizationController.dispose();
    _githubUserController.dispose();
    _projectNameController.dispose();
    _yearController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _organizationNameController,
                decoration: const InputDecoration(labelText: 'Organization Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an organization name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _primaryColorOrganizationController,
                decoration: const InputDecoration(labelText: 'Primary Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a primary color';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _secondaryColorOrganizationController,
                decoration: const InputDecoration(labelText: 'Secondary Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a secondary color';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _githubUserController,
                decoration: const InputDecoration(labelText: 'GitHub User'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a GitHub user';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _branchController,
                decoration: const InputDecoration(labelText: 'Branch'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a branch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
                      year: _yearController.text,
                      branch: _branchController.text,
                    );
                    _viewModel.updateOrganization(organization,context);
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
