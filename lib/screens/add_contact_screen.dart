import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddContactScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const AddContactScreen({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _phone;
  DateTime? _birthDate;
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newContact = {
        'name': _name,
        'email': _email,
        'phone': _phone,
        'birthDate': _birthDate?.toIso8601String(),
        'imagePath': _selectedImage?.path,
      };

      widget.onSave(newContact);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Nome é obrigatório' : null,
                onSaved: (value) => _name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? 'Email inválido' : null,
                onSaved: (value) => _email = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                onSaved: (value) => _phone = value,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _birthDate == null
                        ? 'Data de nascimento: não selecionada'
                        : 'Data de nascimento: ${_birthDate!.toLocal()}'.split(' ')[0],
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Selecionar Data'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _selectedImage == null
                      ? CircleAvatar(radius: 30, child: Icon(Icons.person))
                      : CircleAvatar(radius: 30, backgroundImage: FileImage(_selectedImage!)),
                  Spacer(),
                  TextButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Selecionar da Galeria'),
                  ),
                  TextButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Capturar Imagem'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
