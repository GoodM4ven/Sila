import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts_package;
import 'package:isar/isar.dart';
import 'package:sila/models/contact.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({
    super.key,
    required this.database,
    required this.updateContactsState,
  });

  final Isar database;
  final Function updateContactsState;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool _loading = true;
  List<contacts_package.Contact> _importedContacts = [];
  List<String> _checkedContactIds = [];

  void _toggleInContactIds(String id) {
    setState(() {
      if (_checkedContactIds.contains(id)) {
        _checkedContactIds = _checkedContactIds..remove(id);
      } else {
        _checkedContactIds = _checkedContactIds..add(id);
      }
    });
  }

  void _initializeContacts() async {
    final importedContacts =
        await contacts_package.FlutterContacts.getContacts();
    final contactsCollection = widget.database.collection<Contact>();
    final oldContacts = await contactsCollection.where().findAll();
    List<String> foundContactIds = [];

    for (var oldContact in oldContacts) {
      foundContactIds.add(oldContact.originalId);
    }

    setState(() {
      _importedContacts = importedContacts;
    });

    _importedContacts.map((contact) async {
      final foundContact = await contactsCollection
          .filter()
          .originalIdEqualTo(contact.id)
          .findFirst();

      if (foundContact != null) {
        foundContactIds.add(contact.id);
      }
    });

    setState(() {
      _checkedContactIds = foundContactIds;
    });
  }

  void _submitContacts() async {
    List<Contact> contactsToAdd = [];
    List<Contact> contactsToRemove = [];
    final contactsCollection = widget.database.collection<Contact>();
    final oldContacts = await contactsCollection.where().findAll();

    for (var contact in _importedContacts) {
      if (_checkedContactIds.contains(contact.id)) {
        final foundContact = await contactsCollection
            .filter()
            .originalIdEqualTo(contact.id)
            .findFirst();

        if (foundContact == null) {
          final newContact = Contact()
            ..originalId = contact.id
            ..name = contact.displayName;

          contactsToAdd.add(newContact);
        }
      }
    }

    for (var oldContact in oldContacts) {
      if (!_checkedContactIds.contains(oldContact.originalId)) {
        contactsToRemove.add(oldContact);
      }
    }

    if (contactsToAdd.isNotEmpty) {
      widget.updateContactsState(contactsToAdd);
    }

    if (contactsToRemove.isNotEmpty) {
      widget.updateContactsState(contactsToRemove, true);
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeContacts();

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_checkedContactIds.isEmpty
            ? 'Contacts'
            : 'Contacts (${_checkedContactIds.length})'),
        actions: [
          if (!_loading && _checkedContactIds.isNotEmpty)
            ElevatedButton.icon(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0.0),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              icon: const Icon(
                Icons.check,
                size: 24.0,
                color: Colors.white,
              ),
              label: const Text(
                'Done',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: (() {
                _submitContacts();
                Navigator.pop(context);
              }),
            ),
        ],
      ),
      body: _loading
          ? const CircularProgressIndicator(color: Colors.green)
          : ListView.builder(
              itemCount: _importedContacts.length,
              itemBuilder: (context, index) {
                final contacts_package.Contact contact =
                    _importedContacts[index];

                return CheckboxListTile(
                  title: Text(contact.displayName),
                  value: _checkedContactIds.contains(contact.id),
                  onChanged: (_) => _toggleInContactIds(contact.id),
                );
              },
            ),
    );
  }
}
