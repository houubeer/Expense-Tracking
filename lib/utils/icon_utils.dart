import 'package:flutter/material.dart';

/// Utility class for icon-related operations
class IconUtils {
  /// Converts a string code point to an IconData object
  ///
  /// Returns MaterialIcons.category as fallback if parsing fails
  static IconData fromCodePoint(String codePointStr) {
    try {
      final codePoint = int.parse(codePointStr);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.category;
    }
  }

  /// Converts IconData to a code point string
  static String toCodePointString(IconData icon) {
    return icon.codePoint.toString();
  }
}
