import 'package:flutter/services.dart';

abstract final class AppInputFormatters {
  // Digits and a single decimal point — for monetary amounts and rates
  static final amount = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));

  // Digits only — for whole-number fields like repayment months
  static final integer = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));

  // Free text — deny characters with no legitimate use in financial text:
  // HTML/script delimiters < > "   code-block chars { } [ ]
  // shell metacharacters \ | ^ ~ ` $ @
  static final text = FilteringTextInputFormatter.deny(
    RegExp(r'[<>"{}[\]\\|^~`$@]'),
  );
}
