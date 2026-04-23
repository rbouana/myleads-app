import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts text from a photo using Google ML Kit.
///
/// Explicitly uses the Latin script recognizer, which handles both
/// English and French (plus other western European languages). Accented
/// characters (é, è, ê, ç, à, ô, û, î, ï…) are recognized correctly.
Future<String> recognizeTextFromFile(String filePath) async {
  final inputImage = InputImage.fromFile(File(filePath));
  final recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final result = await recognizer.processImage(inputImage);
    return result.text;
  } finally {
    await recognizer.close();
  }
}
