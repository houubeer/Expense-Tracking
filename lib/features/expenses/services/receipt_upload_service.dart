import 'dart:io';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';

/// Receipt upload service for Supabase Storage
///
/// Handles uploading receipts to Supabase Storage and updating local database
class ReceiptUploadService {
  final AppDatabase _database;
  final SupabaseService _supabaseService;
  final _logger = LoggerService.instance;

  ReceiptUploadService(this._database, this._supabaseService);

  /// Upload a single receipt to Supabase Storage
  ///
  /// Returns the remote URL if successful, null otherwise
  Future<String?> uploadReceipt({
    required int receiptId,
    required String localPath,
    required String organizationId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        _logger.warning('Receipt file not found: $localPath');
        return null;
      }

      // Extract filename
      final fileName = localPath.split(RegExp(r'[/\\]')).last;

      _logger.info('Uploading receipt $receiptId: $fileName');

      // Update status to uploading
      await _database.receiptDao.updateReceipt(
        (await _database.receiptDao.getReceiptById(receiptId))!.copyWith(
          uploadStatus: 'uploading',
        ),
      );

      // Upload to Supabase Storage
      final remoteUrl = await _supabaseService.uploadReceipt(
        file: file,
        organizationId: organizationId,
        fileName: fileName,
      );

      if (remoteUrl != null) {
        // Update receipt with remote URL and uploaded status
        await _database.receiptDao.markReceiptAsUploaded(receiptId, remoteUrl);
        _logger.info('Receipt $receiptId uploaded successfully: $remoteUrl');
        return remoteUrl;
      } else {
        // Mark as failed
        await _database.receiptDao.updateReceipt(
          (await _database.receiptDao.getReceiptById(receiptId))!.copyWith(
            uploadStatus: 'failed',
          ),
        );
        _logger.error('Receipt upload failed for ID $receiptId');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.error('Error uploading receipt $receiptId',
          error: e, stackTrace: stackTrace);

      // Mark as failed
      try {
        final receipt = await _database.receiptDao.getReceiptById(receiptId);
        if (receipt != null) {
          await _database.receiptDao.updateReceipt(
            receipt.copyWith(uploadStatus: 'failed'),
          );
        }
      } catch (_) {}

      return null;
    }
  }

  /// Upload all receipts for an expense
  ///
  /// Returns list of successfully uploaded URLs
  Future<List<String>> uploadReceiptsForExpense({
    required int expenseId,
    required String organizationId,
  }) async {
    try {
      final receipts =
          await _database.receiptDao.getReceiptsForExpense(expenseId);
      final uploadedUrls = <String>[];

      for (final receipt in receipts) {
        // Skip if already uploaded or no local path
        if (receipt.uploadStatus == 'uploaded' || receipt.localPath == null) {
          if (receipt.remoteUrl != null) {
            uploadedUrls.add(receipt.remoteUrl!);
          }
          continue;
        }

        // Upload receipt
        final remoteUrl = await uploadReceipt(
          receiptId: receipt.id,
          localPath: receipt.localPath!,
          organizationId: organizationId,
        );

        if (remoteUrl != null) {
          uploadedUrls.add(remoteUrl);
        }
      }

      _logger.info(
          'Uploaded ${uploadedUrls.length}/${receipts.length} receipts for expense $expenseId');
      return uploadedUrls;
    } catch (e, stackTrace) {
      _logger.error('Error uploading receipts for expense $expenseId',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Upload pending receipts (background sync)
  ///
  /// Uploads all receipts with status != 'uploaded'
  Future<int> uploadPendingReceipts(String organizationId) async {
    try {
      final pendingReceipts = await _database.receiptDao.getPendingUploads();
      int successCount = 0;

      _logger.info('Found ${pendingReceipts.length} pending receipts to upload');

      for (final receipt in pendingReceipts) {
        if (receipt.localPath == null) continue;

        final remoteUrl = await uploadReceipt(
          receiptId: receipt.id,
          localPath: receipt.localPath!,
          organizationId: organizationId,
        );

        if (remoteUrl != null) {
          successCount++;
        }
      }

      _logger.info('Successfully uploaded $successCount/${pendingReceipts.length} pending receipts');
      return successCount;
    } catch (e, stackTrace) {
      _logger.error('Error uploading pending receipts',
          error: e, stackTrace: stackTrace);
      return 0;
    }
  }
}
