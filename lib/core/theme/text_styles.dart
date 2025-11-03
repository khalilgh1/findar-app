import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle body = TextStyle(fontSize: 13);
}
/*
import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle heading1({required Color color}) {
    return TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  }

  static TextStyle heading2({required Color color}) {
    return TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  }

  static TextStyle heading3({required Color color}) {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.w900);
  }

  static TextStyle body({required Color color}) {
    return TextStyle(fontSize: 13);
  }
}
*/