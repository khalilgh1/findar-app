import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/filtering');
          },
          child: const Text('Go to Filtering Screen'),
        ),
      ),
    );
  }
}
