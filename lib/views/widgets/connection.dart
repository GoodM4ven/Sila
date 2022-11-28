import 'package:flutter/material.dart';
import 'package:sila/models/contact.dart';

class ConnectionWidget extends StatelessWidget {
  const ConnectionWidget({
    super.key,
    required this.contacts,
    required this.tabIndex,
    required this.toggleContactIsConnectedStatus,
  });

  final List<Contact> contacts;
  final int tabIndex;
  final Function toggleContactIsConnectedStatus;

  @override
  Widget build(BuildContext context) {
    final bool isConnectedList = tabIndex == 1;
    final List<Contact> filteredContacts = contacts
        .where((contact) => contact.isConnected == isConnectedList)
        .toList()
      ..sort((a, b) {
        return isConnectedList
            ? b.order.compareTo(a.order)
            : a.order.compareTo(b.order);
      })
      ..toList();

    return ListView.separated(
      itemCount: filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = filteredContacts[index];

        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 10 : 0),
          child: ListTile(
            title: Text(contact.name),
            trailing: IconButton(
              icon: Icon(!contact.isConnected ? Icons.link : Icons.link_off),
              onPressed: () => toggleContactIsConnectedStatus(contact),
            ),
          ),
        );
      },
      separatorBuilder: ((context, index) => const Divider()),
    );
  }
}
