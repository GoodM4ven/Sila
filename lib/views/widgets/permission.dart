import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class PermissionWidget extends StatelessWidget {
  const PermissionWidget({
    super.key,
    required this.updatePermissionState,
  });

  final Function updatePermissionState;

  void _requestPermission() async {
    if (await FlutterContacts.requestPermission()) {
      updatePermissionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'The application requires the permission to read your contacts in order to function.',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      offset: Offset(0.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                    ),
                  ],
                ),
              ),
              onPressed: _requestPermission,
              child: const Text('Grant Permissions'),
            ),
          ),
        ],
      ),
    );
  }
}
