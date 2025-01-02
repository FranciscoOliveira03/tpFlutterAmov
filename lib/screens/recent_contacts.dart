import 'package:flutter/material.dart';
import 'package:tpflutter/models/contact.dart';
import 'package:tpflutter/shared_recent.dart';

class RecentContactsScreen extends StatefulWidget {
  @override
  _RecentContactsScreenState createState() => _RecentContactsScreenState();
}

class _RecentContactsScreenState extends State<RecentContactsScreen> {
  late Future<List<Contact>> _recentContactsFuture;

  @override
  void initState() {
    super.initState();
    _recentContactsFuture = RecentContactsManager().getRecentContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos Recentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _recentContactsFuture = RecentContactsManager().getRecentContacts();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Contact>>(
        future: _recentContactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar contatos recentes'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum contato recente'));
          }

          final recentContacts = snapshot.data!;
          return ListView.builder(
            itemCount: recentContacts.length,
            itemBuilder: (context, index) {
              final contact = recentContacts[index];
              return ListTile(
                title: Text(contact.name),
                subtitle: Text(contact.email),
                onTap: () {

                },
              );
            },
          );
        },
      ),
    );
  }
}
