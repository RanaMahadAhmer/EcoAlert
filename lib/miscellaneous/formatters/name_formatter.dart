import 'package:flutter/services.dart';

class NameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final filteredText = newValue.text.replaceAll(RegExp(r'[^a-zA-Z ]'), '');

    String formattedName = '';
    final words = filteredText.split(' ');

    for (var word in words) {
      if (word.isNotEmpty) {
        formattedName +=
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()} ';
      }
    }
    formattedName = formattedName.trim();

    if (words.length > 1 && words.last == '') formattedName += ' ';
    return TextEditingValue(
      text: formattedName,
      selection: TextSelection.collapsed(offset: formattedName.length),
    );
  }
}
