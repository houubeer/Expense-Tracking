import 'package:equatable/equatable.dart';

/// Receipt attachment model for UI layer
///
/// Represents a single receipt file (image or PDF) attached to an expense.
/// Supports both local files (not yet uploaded) and remote files (uploaded to Supabase).
class ReceiptAttachment extends Equatable {
  /// Unique identifier (database ID, null for new receipts)
  final int? id;

  /// Local file path (for preview and upload)
  final String? localPath;

  /// Remote URL (Supabase Storage URL after upload)
  final String? remoteUrl;

  /// Original filename
  final String fileName;

  /// File type extension (jpg, png, pdf, etc.)
  final String fileType;

  /// File size in bytes
  final int? fileSize;

  /// Upload status: local, uploading, uploaded, failed
  final String uploadStatus;

  const ReceiptAttachment({
    this.id,
    this.localPath,
    this.remoteUrl,
    required this.fileName,
    required this.fileType,
    this.fileSize,
    this.uploadStatus = 'local',
  });

  /// Check if receipt is only stored locally
  bool get isLocal => uploadStatus == 'local' && remoteUrl == null;

  /// Check if receipt is currently being uploaded
  bool get isUploading => uploadStatus == 'uploading';

  /// Check if receipt is successfully uploaded
  bool get isUploaded => uploadStatus == 'uploaded' && remoteUrl != null;

  /// Check if upload failed
  bool get hasFailed => uploadStatus == 'failed';

  /// Get display path (remote if available, otherwise local)
  String get displayPath => remoteUrl ?? localPath ?? '';

  /// Check if file is an image
  bool get isImage {
    final lowerType = fileType.toLowerCase();
    return lowerType == 'jpg' ||
        lowerType == 'jpeg' ||
        lowerType == 'png' ||
        lowerType == 'gif' ||
        lowerType == 'webp';
  }

  /// Check if file is a PDF
  bool get isPdf => fileType.toLowerCase() == 'pdf';

  /// Format file size for display
  String get formattedSize {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Create a copy with updated fields
  ReceiptAttachment copyWith({
    int? id,
    String? localPath,
    String? remoteUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? uploadStatus,
  }) {
    return ReceiptAttachment(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadStatus: uploadStatus ?? this.uploadStatus,
    );
  }

  /// Create from file path
  factory ReceiptAttachment.fromFilePath(String path) {
    final parts = path.split(RegExp(r'[/\\]'));
    final fileName = parts.isNotEmpty ? parts.last : path;
    final fileType = fileName.split('.').last;

    return ReceiptAttachment(
      localPath: path,
      fileName: fileName,
      fileType: fileType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        localPath,
        remoteUrl,
        fileName,
        fileType,
        fileSize,
        uploadStatus,
      ];
}
