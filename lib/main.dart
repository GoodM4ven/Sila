import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts_page;
import 'package:isar/isar.dart';
import 'package:sila/models/contact.dart';
import 'package:sila/views/pages/contacts.dart';
import 'package:sila/views/widgets/bottom_navigation_bar.dart';
import 'package:sila/views/widgets/connection.dart';
import 'package:sila/views/widgets/permission.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sila',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(title: 'Sila'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final int _tabsCount = 2;
  int _currentTabIndex = 0;
  bool _loading = true;

  late TabController _tabController;
  late bool _permissionGranted;
  late Isar _database;
  late List<Contact> _contacts;

  void _initializePermission() async {
    final permission =
        await contacts_page.FlutterContacts.requestPermission(readonly: true);

    setState(() => _permissionGranted = permission);
  }

  void _initializeContacts() async {
    _database = await Isar.open([ContactSchema]);
    final contacts = await _database.collection<Contact>().where().findAll();

    setState(() {
      _contacts = contacts;
      _loading = false;
    });
  }

  void _updatePermissionState() {
    setState(() => _permissionGranted = true);
  }

  void _updateContactsState(List<Contact> contacts,
      [bool removeInstead = false]) async {
    await _database.writeTxn(() async {
      for (var contact in contacts) {
        if (!removeInstead) {
          await _database.contacts.put(contact);
        } else {
          await _database.contacts.delete(contact.id);
        }
      }
    });

    final updatedContacts =
        await _database.collection<Contact>().where().findAll();

    setState(() => _contacts = updatedContacts);
  }

  @override
  void initState() {
    super.initState();
    _initializePermission();
    _initializeContacts();

    _tabController = TabController(vsync: this, length: _tabsCount);

    _tabController.addListener(() {
      setState(() => _currentTabIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!_loading && _permissionGranted)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactsPage(
                      database: _database,
                      updateContactsState: _updateContactsState,
                    ),
                  ),
                );
              },
              tooltip: 'Add Contacts',
              icon: const Icon(
                Icons.add,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : _permissionGranted
              ? TabBarView(
                  controller: _tabController,
                  children: Iterable<int>.generate(_tabsCount).map((index) {
                    return ConnectionWidget(
                      tabIndex: index,
                      contacts: _contacts,
                    );
                  }).toList(),
                )
              : PermissionWidget(
                  updatePermissionState: _updatePermissionState,
                ),
      bottomNavigationBar: !_loading && _permissionGranted
          ? BottomNavigationBarWidget(
              tabController: _tabController,
              currentTabIndex: _currentTabIndex,
            )
          : null,
    );
  }
}
