import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/core/models/models.dart';
import 'package:sec/domain/repositories/sec_repository.dart';
import 'package:sec/presentation/ui/screens/event_detail/sponsor/sponsor_view_model.dart';
import 'package:sec/presentation/ui/widgets/widgets.dart';

import '../../../../../core/di/dependency_injection.dart';

class AddSponsorScreen extends StatefulWidget {
  final Sponsor? sponsor;
  final SponsorViewModel sponsorViewModel = getIt<SponsorViewModel>();
  AddSponsorScreen({super.key, this.sponsor});

  @override
  State<AddSponsorScreen> createState() => _AddSponsorScreenState();
}

class _AddSponsorScreenState extends State<AddSponsorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _logoController;
  late final TextEditingController _websiteController;
  late String _selectedCategory;

  final List<String> _categories = [
    'Patrocinador Principal',
    'Patrocinador Gold',
    'Patrocinador Silver',
    'Patrocinador Bronze',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sponsor?.name ?? '');
    _logoController = TextEditingController(text: widget.sponsor?.logo ?? '');
    _websiteController = TextEditingController(
      text: widget.sponsor?.website ?? '',
    );
    _selectedCategory = widget.sponsor?.type ?? _categories.first;
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
    final isEditing = widget.sponsor != null;

    return FormScreenWrapper(
      pageTitle: isEditing ? 'Editar Sponsor' : 'Crear Sponsor',
      widgetFormChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(
                isEditing ? 'Editando Sponsor' : 'Creando Sponsor',
                style: AppFonts.titleHeadingForm,
              ),
              SectionInputForm(
                label: 'Nombre*',
                childInput: TextFormField(
                  controller: _nameController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: 'Introduce el nombre del Sponsor',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nombre' : null,
                ),
              ),

              SectionInputForm(
                label: 'Logo*',
                childInput: TextFormField(
                  maxLines: 1,
                  controller: _logoController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: 'Introduce la URL del logo',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Logo' : null,
                ),
              ),

              SectionInputForm(
                label: 'Web*',
                childInput: TextFormField(
                  maxLines: 1,
                  controller: _websiteController,
                  decoration: AppDecorations.textFieldDecoration.copyWith(
                    hintText: 'Introduce la URL de la web',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Web' : null,
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
                        );
                        widget.sponsorViewModel.addSponsor(sponsor);
                        if (context.mounted) {
                          Navigator.pop(context, sponsor);
                        }
                      }
                    },
                    child: Text(isEditing ? 'Actualizar' : 'Guardar'),
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
