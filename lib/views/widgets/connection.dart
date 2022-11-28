import 'package:flutter/material.dart';
import 'package:sila/models/contact.dart';

class ConnectionWidget extends StatelessWidget {
  const ConnectionWidget({
    super.key,
    required this.contacts,
    required this.tabIndex,
  });

  final List<Contact> contacts;
  final int tabIndex; // TODO utilize

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(contacts[index].name),
        );
      },
      separatorBuilder: ((context, index) => const Divider()),
    );
  }
}
