import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tpflutter/models/contact.dart';
import 'package:tpflutter/shared_recent.dart';

class EditContactScreen extends StatefulWidget {
  final Contact contact; // O contato a ser editado
  final Function(Contact) onUpdate;

  const EditContactScreen({
    Key? key,
    required this.contact,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditContactScreenState createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  DateTime? _birthDate;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _emailController = TextEditingController(text: widget.contact.email);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _birthDate = widget.contact.birthDate;
    _selectedImage = widget.contact.imagePath != null
        ? File(widget.contact.imagePath!)
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  void _updateContact() async {
    if (_formKey.currentState!.validate()) {
      final updatedContact = Contact(
        id: widget.contact.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        birthDate: _birthDate,
        imagePath: _selectedImage?.path,
        locations: widget.contact.locations,
      );

      widget.onUpdate(updatedContact);

      final recentManager = RecentContactsManager();
      await recentManager.saveRecentContact(updatedContact);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Nome é obrigatório' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@') ? 'Email inválido' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Telefone é obrigatório' : null,
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
                onPressed: _updateContact,
                child: Text('Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
