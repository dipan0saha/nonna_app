import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'backup_service.dart';

/// Handler for GDPR-compliant user data export
/// 
/// Generates ZIP files containing all user data and provides download/email functionality
class DataExportHandler {
  final BackupService _backupService;

  DataExportHandler({
    BackupService? backupService,
  }) : _backupService = backupService ?? BackupService();

  // ==========================================
  // Data Export
  // ==========================================

  /// Export all user data as a ZIP file
  /// 
  /// [userId] The user ID to export data for
  /// [includePhotos] Whether to include photo backups (default: true)
  /// Returns the path to the generated ZIP file
  Future<String> exportUserDataAsZip(
    String userId, {
    bool includePhotos = true,
  }) async {
    try {
      debugPrint('📦 Starting data export for user $userId');

      // Create temporary directory for export
      final tempDir = Directory.systemTemp.createTempSync('nonna_export_');
      final exportDir = Directory('${tempDir.path}/$userId');
      await exportDir.create(recursive: true);

      // Export user data to JSON
      final userDataJson = await _backupService.exportUserData(userId);
      final userDataFile = File('${exportDir.path}/user_data.json');
      await userDataFile.writeAsString(userDataJson);

      debugPrint('✅ User data exported to JSON');

      // Export photos if requested
      if (includePhotos) {
        try {
          final backedUpPhotos = await _backupService.backupPhotos(userId);
          debugPrint('✅ ${backedUpPhotos.length} photos backed up');

          // Create photos manifest
          final photosManifest = {
            'total_photos': backedUpPhotos.length,
            'backup_paths': backedUpPhotos,
          };
          final photosManifestFile = File('${exportDir.path}/photos_manifest.json');
          await photosManifestFile.writeAsString(jsonEncode(photosManifest));
        } catch (e) {
          debugPrint('⚠️ Error backing up photos: $e');
          // Continue without photos
        }
      }

      // Create README file
      final readmeFile = File('${exportDir.path}/README.txt');
      await readmeFile.writeAsString(_generateReadmeContent(userId));

      // Create ZIP archive
      final zipPath = await _createZipArchive(exportDir, tempDir);
      
      debugPrint('✅ Data export completed: $zipPath');

      // Clean up temporary directory (keep ZIP file)
      await exportDir.delete(recursive: true);

      return zipPath;
    } catch (e) {
      debugPrint('❌ Error exporting user data: $e');
      rethrow;
    }
  }

  /// Create ZIP archive from directory
  Future<String> _createZipArchive(Directory sourceDir, Directory tempDir) async {
    try {
      final archive = Archive();

      // Add all files from source directory to archive
      await for (final entity in sourceDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: sourceDir.path);
          final fileBytes = await entity.readAsBytes();
          
          archive.addFile(ArchiveFile(
            relativePath,
            fileBytes.length,
            fileBytes,
          ));
        }
      }

      // Encode archive as ZIP
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) {
        throw Exception('Failed to create ZIP archive');
      }

      // Write ZIP file
      final zipPath = '${tempDir.path}/nonna_data_export.zip';
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes);

      return zipPath;
    } catch (e) {
      debugPrint('❌ Error creating ZIP archive: $e');
      rethrow;
    }
  }

  /// Generate README content for the export
  String _generateReadmeContent(String userId) {
    return '''
NONNA APP - USER DATA EXPORT
=============================

User ID: $userId
Export Date: ${DateTime.now().toIso8601String()}

This ZIP file contains all of your personal data from the Nonna app, 
exported in compliance with GDPR data portability requirements.

FILE CONTENTS:
--------------
1. user_data.json - All your personal data in JSON format, including:
   - Profile information
   - User statistics
   - Baby memberships
   - Photos metadata
   - Comments
   - Events
   - Registry items
   - And more...

2. photos_manifest.json - List of your uploaded photos (if included)

3. README.txt - This file

DATA FORMAT:
------------
The data is provided in JSON format for easy machine readability and 
portability to other systems. You can use any JSON viewer or text editor 
to view the contents.

QUESTIONS?
----------
If you have any questions about your data export, please contact us at:
support@nonnaapp.com

Thank you for using Nonna!
''';
  }

  // ==========================================
  // Export Status
  // ==========================================

  /// Get the estimated size of user data export
  Future<int> estimateExportSize(String userId) async {
    try {
      // Export data to calculate size
      final userDataJson = await _backupService.exportUserData(userId);
      final jsonSize = utf8.encode(userDataJson).length;

      // Estimate photo sizes (this is a rough estimate)
      // In a real implementation, you would query actual photo sizes
      final photoCount = 0; // Would be calculated from actual data
      final estimatedPhotoSize = photoCount * 500000; // Assume 500KB per photo

      return jsonSize + estimatedPhotoSize;
    } catch (e) {
      debugPrint('❌ Error estimating export size: $e');
      return 0;
    }
  }

  // ==========================================
  // Email Delivery
  // ==========================================

  /// Email the data export to the user
  /// 
  /// [userId] The user ID
  /// [email] The email address to send to
  /// [zipPath] Path to the ZIP file
  Future<void> emailDataExport(
    String userId,
    String email,
    String zipPath,
  ) async {
    try {
      // In a real implementation, this would:
      // 1. Upload the ZIP file to temporary storage
      // 2. Send an email with a download link
      // 3. Set an expiration time for the download
      // 4. Clean up the file after expiration
      
      debugPrint('📧 Would email data export to $email');
      debugPrint('📦 ZIP file: $zipPath');
      
      // For now, we just log the operation
      // Actual implementation would use an email service
    } catch (e) {
      debugPrint('❌ Error emailing data export: $e');
      rethrow;
    }
  }

  // ==========================================
  // Download Link Generation
  // ==========================================

  /// Generate a secure download link for the export
  /// 
  /// [userId] The user ID
  /// [zipPath] Path to the ZIP file
  /// Returns a secure download URL
  Future<String?> generateDownloadLink(String userId, String zipPath) async {
    try {
      // In a real implementation, this would:
      // 1. Upload the ZIP to temporary storage (e.g., Supabase Storage)
      // 2. Generate a signed URL with expiration
      // 3. Return the URL
      
      debugPrint('🔗 Would generate download link for $zipPath');
      
      // For now, return null to indicate the feature is not yet implemented
      return null;
    } catch (e) {
      debugPrint('❌ Error generating download link: $e');
      return null;
    }
  }
}
