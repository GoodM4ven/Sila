import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:sila/views/pages/contacts.dart';

class AddContactsButtonWidget extends StatelessWidget {
  const AddContactsButtonWidget({
    super.key,
    required this.database,
    required this.updateContactsState,
  });

  final Isar database;
  final Function updateContactsState;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactsPage(
                database: database,
                updateContactsState: updateContactsState,
              ),
            ),
          );
        },
        tooltip: 'Add Contacts',
        icon: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
