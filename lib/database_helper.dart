import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tpflutter/models/contact.dart';
import 'package:tpflutter/models/location.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT,
            birthDate TEXT,
            imagePath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contactId INTEGER,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (contactId) REFERENCES contacts (id)
          )
        ''');
      },
    );
  }

  Future<void> insertContact(Contact contact) async {
    final db = await database;

    final contactId = await db.insert('contacts', {
      'name': contact.name,
      'email': contact.email,
      'phone': contact.phone,
      'birthDate': contact.birthDate?.toIso8601String(),
      'imagePath': contact.imagePath,
    });

    for (final location in contact.locations) {
      await db.insert('locations', {
        'contactId': contactId,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': location.timestamp.toIso8601String(),
      });
    }
  }

  Future<List<Contact>> getContacts() async {
    final db = await database;

    final contactsData = await db.query('contacts');
    final List<Contact> contacts = [];

    for (final contactData in contactsData) {
      final contactId = contactData['id'] as int;

      final locationsData = await db.query(
        'locations',
        where: 'contactId = ?',
        whereArgs: [contactId],
      );

      final locations = locationsData.map((locationData) {
        return Location(
          latitude: locationData['latitude'] as double,
          longitude: locationData['longitude'] as double,
          timestamp: DateTime.parse(locationData['timestamp'] as String),
        );
      }).toList();

      contacts.add(Contact(
        id: contactId,
        name: contactData['name'] as String,
        email: contactData['email'] as String,
        phone: contactData['phone'] as String,
        birthDate: contactData['birthDate'] != null
            ? DateTime.parse(contactData['birthDate'] as String)
            : null,
        imagePath: contactData['imagePath'] as String?,
        locations: locations,
      ));
    }

    return contacts;
  }

  Future<void> updateContact(Contact contact) async {
    final db = await database;

    await db.update(
      'contacts',
      {
        'name': contact.name,
        'email': contact.email,
        'phone': contact.phone,
        'birthDate': contact.birthDate?.toIso8601String(),
        'imagePath': contact.imagePath,
      },
      where: 'id = ?',
      whereArgs: [contact.id],
    );

    await db.delete(
      'locations',
      where: 'contactId = ?',
      whereArgs: [contact.id],
    );

    for (final location in contact.locations) {
      await db.insert('locations', {
        'contactId': contact.id,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': location.timestamp.toIso8601String(),
      });
    }
  }

  Future<void> insertLocation(Location location, int contactId) async {
    final db = await database;

    await db.insert('locations', {
      'contactId': contactId,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': location.timestamp.toIso8601String(),
    });
  }

  Future<void> deleteContact(int contactId) async {
    final db = await database;

    await db.delete(
      'locations',
      where: 'contactId = ?',
      whereArgs: [contactId],
    );

    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
    );
  }

}
