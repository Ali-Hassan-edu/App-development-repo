import 'package:flutter/material.dart';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  final String name = 'ALI hassan';
  final String email = 'waqaranjum@gmail.com';
  final String phone = '03211532010';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile App'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/123.jpeg'),
              ),
              SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
              ),
              SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                phone,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}