import 'package:flutter/services.dart';

abstract final class AppInputFormatters {
  static TextInputFormatter get numbersOnly =>
      FilteringTextInputFormatter.digitsOnly;

  static TextInputFormatter get decimal =>
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

  static TextInputFormatter get amount =>
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

  static TextInputFormatter get text =>
      FilteringTextInputFormatter.allow(RegExp(r'.*'));
}
