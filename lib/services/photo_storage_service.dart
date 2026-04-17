import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Manages persistent photo storage for profile and contact images.
///
/// Photos are copied into the app's private documents directory under a
/// hidden `.images/` folder so they survive app updates and are not
/// visible in the system gallery. Two sub-directories are maintained:
///   - `.images/profile_pictures/`  — user profile photos
///   - `.images/contact_pictures/`  — contact photos
///
/// All methods fall back to the original [sourcePath] on any error so
/// callers never have to handle a null path in the happy path.
class PhotoStorageService {
  PhotoStorageService._();

  // ── Public API ──────────────────────────────────────────────────────────

  /// Copies [sourcePath] into the `profile_pictures` directory.
  ///
  /// Returns the new persistent path, or [sourcePath] if the copy fails.
  /// Returns [sourcePath] unchanged on web (file I/O not available).
  static Future<String?> saveProfilePhoto(String sourcePath) async {
    if (kIsWeb) return sourcePath;
    return _copyToDir(sourcePath, 'profile_pictures');
  }

  /// Copies [sourcePath] into the `contact_pictures` directory.
  ///
  /// Returns the new persistent path, or [sourcePath] if the copy fails.
  /// Returns [sourcePath] unchanged on web.
  static Future<String?> saveContactPhoto(String sourcePath) async {
    if (kIsWeb) return sourcePath;
    return _copyToDir(sourcePath, 'contact_pictures');
  }

  // ── Internal ────────────────────────────────────────────────────────────

  static Future<String?> _copyToDir(
      String sourcePath, String subDir) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetDir =
          Directory(p.join(appDir.path, '.images', subDir));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final ext = p.extension(sourcePath);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
      final targetPath = p.join(targetDir.path, fileName);
      await File(sourcePath).copy(targetPath);
      return targetPath;
    } catch (_) {
      // If anything goes wrong (permissions, disk full, etc.) fall back
      // to the original path so the photo still displays.
      return sourcePath;
    }
  }
}
