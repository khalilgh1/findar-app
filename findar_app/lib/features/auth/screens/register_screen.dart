import 'package:flutter/material.dart';


class RegisterScreen extends StatelessWidget {
  RegisterScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Screen'),
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
