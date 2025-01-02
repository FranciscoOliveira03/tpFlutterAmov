import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tpflutter/models/contact.dart';

class RecentContactsManager {

  static const String _key = 'recent_contacts';

  Future<void> saveRecentContact(Contact contact) async {
    final prefs = await SharedPreferences.getInstance();

    final recentContacts = await getRecentContacts();

    recentContacts.removeWhere((c) => c.id == contact.id);

    recentContacts.insert(0, contact);

    if (recentContacts.length > 10) {
      recentContacts.removeRange(10, recentContacts.length);
    }

    await _saveContactsToPrefs(prefs, recentContacts);
  }

  Future<List<Contact>> getRecentContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((item) => Contact.fromJson(item)).toList();
  }

  Future<void> _saveContactsToPrefs(SharedPreferences prefs, List<Contact> contacts) async {
    final jsonList = contacts.map((contact) => contact.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_key, jsonString);
  }
}
