import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tpflutter/database_helper.dart';
import 'package:tpflutter/models/contact.dart';
import 'package:tpflutter/screens/recent_contacts.dart';
import 'add_contact_screen.dart';
import 'contact_details.dart';

class ContactsListScreen extends StatefulWidget {
  @override
  _ContactsListScreenState createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Contact> _contacts = [];
  Map<int, bool> _expandedContacts = {};

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _dbHelper.getContacts();
    setState(() {
      _contacts = contacts;
      _expandedContacts = {for (var i = 0; i < contacts.length; i++) i: false};
    });
  }

  Future<void> _addContact(Contact contact) async {
    await _dbHelper.insertContact(contact);
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddContactScreen(
                      onSave: (newContact) async {
                        await _addContact(newContact);
                      },
                    );
                  },
                ),
              );

              if (result == true) {
                _loadContacts();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RecentContactsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('Nenhum contato adicionado'))
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          final isExpanded = _expandedContacts[index] ?? false;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: contact.imagePath != null
                      ? CircleAvatar(
                    backgroundImage: FileImage(File(contact.imagePath!)),
                  )
                      : CircleAvatar(child: Text(contact.name[0])),
                  title: Text(contact.name),
                  subtitle: Text(contact.email),
                  trailing: IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () {
                      setState(() {
                        _expandedContacts[index] = !isExpanded;
                      });
                    },
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactDetailsScreen(
                          contact: contact,
                          onContactUpdated: (updatedContact) async {
                            await _dbHelper.updateContact(updatedContact);

                            _loadContacts();
                          },
                        ),
                      ),
                    );

                    if (result == true) {
                      _loadContacts();
                    }
                  },
                ),
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Telefone: ${contact.phone ?? 'N/A'}"),
                        Text("Data de Nascimento: ${contact.birthDate ?? 'N/A'}"),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
