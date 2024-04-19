import 'package:flutter/services.dart';

class EmailFormatter extends TextInputFormatter {
  String _validMarkers({required String text, required String sign}) {
    String formattedText = (text.split(sign).length - 1 > 1)
        ? text.substring(0, text.length - 1)
        : text;
    formattedText = (formattedText.contains("@") && formattedText.contains("."))
        ? ((formattedText.indexOf("@") + 1 < formattedText.indexOf("."))
            ? formattedText
            : formattedText.substring(0, formattedText.length - 1))
        : formattedText;
    formattedText = formattedText.contains("@")
        ? formattedText
        : formattedText.replaceAll(".", "");
    formattedText = formattedText.indexOf("@") != 0
        ? formattedText
        : formattedText.replaceAll("@", "");
    formattedText = formattedText.indexOf("-") != 0
        ? formattedText
        : formattedText.replaceAll("-", "");
    formattedText = formattedText.indexOf("_") != 0
        ? formattedText
        : formattedText.replaceAll("_", "");
    return formattedText;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String filteredText =
        newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9_\-@. ]'), '');

    filteredText = _validMarkers(
            text: _validMarkers(text: filteredText, sign: "@"), sign: ".")
        .trim();

    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}
