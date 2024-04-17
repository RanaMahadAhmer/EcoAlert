import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Remove all non-digit characters
    final cleanedText = text.replaceAll(RegExp(r'[^\d]'), '');

    // Check if cleanedText is empty, which can happen if the user deletes everything
    if (cleanedText.isEmpty) {
      return TextEditingValue(
        text: cleanedText,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Build the formatted phone number string, considering the length of cleanedText
    String formattedText = '';

    formattedText += (cleanedText.length >= 12)
        ? '+${cleanedText.substring(0, 2)}-${cleanedText.substring(2, 5)}'
            '-${cleanedText.substring(5, 12)}'
        : formattedText += cleanedText;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
