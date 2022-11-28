import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts_page;
import 'package:isar/isar.dart';
import 'package:sila/models/contact.dart';
import 'package:sila/views/widgets/add_contacts_button.dart';
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
  late bool _allAreConnected;

  void _initializePermission() async {
    final permission =
        await contacts_page.FlutterContacts.requestPermission(readonly: true);

    setState(() => _permissionGranted = permission);
  }

  void _updatePermissionState() {
    setState(() => _permissionGranted = true);
  }

  void _initializeContacts() async {
    _database = await Isar.open([ContactSchema]);
    _refreshContacts();

    setState(() => _loading = false);
  }

  void _refreshContacts() async {
    final savedContacts =
        await _database.collection<Contact>().where().findAll();

    final allAreConnected = await _database.contacts.where().isNotEmpty() &&
        await _database.contacts
            .where()
            .filter()
            .isConnectedEqualTo(false)
            .isEmpty();

    setState(() {
      _contacts = savedContacts;
      _allAreConnected = allAreConnected;
    });
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

    _refreshContacts();
  }

  void _toggleContactIsConnectedStatus(Contact contact) async {
    await _database.writeTxn(() async {
      contact.isConnected = !contact.isConnected;
      await _database.contacts.put(contact);
    });

    _refreshContacts();
  }

  void _resetContacts() async {
    final lastOrderedContact =
        await _database.contacts.where().sortByOrderDesc().findFirst();
    final int maxOrder = lastOrderedContact!.order;
    final random = Random();
    List<int> generatedOrders = [];

    await _database.writeTxn(() async {
      for (var contact in _contacts) {
        var randomOrder = random.nextInt(maxOrder + 1);

        while (generatedOrders.contains(randomOrder)) {
          randomOrder = random.nextInt(maxOrder + 1);
        }

        generatedOrders.add(randomOrder);

        contact.order = randomOrder;
        contact.isConnected = false;

        await _database.contacts.put(contact);
      }
    });

    _refreshContacts();
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
          if (!_loading && _permissionGranted && _currentTabIndex == 0)
            AddContactsButtonWidget(
              database: _database,
              updateContactsState: _updateContactsState,
            ),
          if (!_loading &&
              _permissionGranted &&
              _currentTabIndex == 1 &&
              _allAreConnected)
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () => _resetContacts(),
                tooltip: 'Add Contacts',
                icon: const Icon(
                  Icons.restart_alt,
                ),
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
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: Iterable<int>.generate(_tabsCount).map((index) {
                    return ConnectionWidget(
                      tabIndex: index,
                      contacts: _contacts,
                      toggleContactIsConnectedStatus:
                          _toggleContactIsConnectedStatus,
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
