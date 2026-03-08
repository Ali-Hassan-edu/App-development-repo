// Code snippet to fix profile update bug and improve responsive UI in settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),  
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Username'),
              onChanged: (value) {
                username = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateUsername();
              },
              child: Text('Update Username'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateUsername() async {
    // Call the API to update username 
    // ...
    // After successful update, refresh the state
    setState(() {});
  }
}