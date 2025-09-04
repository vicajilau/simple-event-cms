import 'package:flutter/material.dart';
import 'package:sec/core/config/app_decorations.dart';
import 'package:sec/core/config/app_fonts.dart';
import 'package:sec/ui/widgets/form_screen_wrapper.dart';
import 'package:sec/ui/widgets/section_input_form.dart';

class AddSponsorScreen extends StatefulWidget {
  const AddSponsorScreen({super.key});

  @override
  State<AddSponsorScreen> createState() => _AddSponsorScreenState();
}

class _AddSponsorScreenState extends State<AddSponsorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _logoController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  String _selectedCategory = 'Principal';

  final List<String> _categories = ['Principal', 'Gold', 'Silver', 'Bronze'];

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormScreenWrapper(
      pageTitle: 'Creación evento',
      widgetFormChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text('Creando Sponsor', style: AppFonts.titleHeadingForm),
              SectionInputForm(
                label: 'Nombre*',
                childInput: TextFormField(
                  maxLines: 1,
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: 'Introduce el nombre del Sponsor',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nombre';
                    }
                    return null;
                  },
                ),
              ),

              SectionInputForm(
                label: 'Logo*',
                childInput: TextFormField(
                  maxLines: 1,
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: 'Introduce la URL del logo',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Logo';
                    }
                    return null;
                  },
                ),
              ),

              SectionInputForm(
                label: 'Web*',
                childInput: TextFormField(
                  maxLines: 1,
                  decoration: AppDecorations.textfieldDecoration.copyWith(
                    hintText: 'Introduce la URL de la web',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Web';
                    }
                    return null;
                  },
                ),
              ),

              Text(
                'Categoria',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.blue),
                      ),
                      child: const Text('Aceptar'),
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
