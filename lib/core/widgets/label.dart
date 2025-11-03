import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel({super.key,required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}