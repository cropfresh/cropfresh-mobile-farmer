import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_lib;

/// PhotoUploadService - Story 3.2 (AC5, AC7)
/// 
/// Handles photo upload with:
/// - Presigned URL workflow (AC5) - Phase 2 will connect to real API
/// - Progress tracking (AC5)
/// - Network failure handling with retry (AC5)
/// - Offline queue with Hive persistence (AC7)
/// - Background sync when connectivity restored (AC7)

// ============================================================================
// Photo Upload Status
// ============================================================================

enum PhotoUploadStatus {
  pending,        // Queued for upload
  uploading,      // Currently uploading
  validating,     // Uploaded, waiting for validation
  completed,      // Successfully uploaded and validated
  failed,         // Upload failed, will retry
}

// ============================================================================
// Photo Upload Item Model
// ============================================================================

class PhotoUploadItem {
  final String id;
  final String localPath;
  final int listingId;
  final String cropType;
  final Map<String, dynamic> metadata;
  PhotoUploadStatus status;
  int retryCount;
  String? photoId;
  String? uploadUrl;
  String? errorMessage;
  final DateTime createdAt;
  DateTime? uploadedAt;

  PhotoUploadItem({
    required this.id,
    required this.localPath,
    required this.listingId,
    required this.cropType,
    required this.metadata,
    this.status = PhotoUploadStatus.pending,
    this.retryCount = 0,
    this.photoId,
    this.uploadUrl,
    this.errorMessage,
    DateTime? createdAt,
    this.uploadedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'localPath': localPath,
    'listingId': listingId,
    'cropType': cropType,
    'metadata': metadata,
    'status': status.name,
    'retryCount': retryCount,
    'photoId': photoId,
    'uploadUrl': uploadUrl,
    'errorMessage': errorMessage,
    'createdAt': createdAt.toIso8601String(),
    'uploadedAt': uploadedAt?.toIso8601String(),
  };

  factory PhotoUploadItem.fromJson(Map<String, dynamic> json) {
    return PhotoUploadItem(
      id: json['id'] as String,
      localPath: json['localPath'] as String,
      listingId: json['listingId'] as int,
      cropType: json['cropType'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      status: PhotoUploadStatus.values.byName(json['status'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      photoId: json['photoId'] as String?,
      uploadUrl: json['uploadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'] as String)
          : null,
    );
  }
}

// ============================================================================
// Photo Upload Service
// ============================================================================

class PhotoUploadService extends ChangeNotifier {
  static const String _boxName = 'photo_upload_queue';
  static const int _maxRetries = 3;

  Box<Map>? _box;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isProcessing = false;
  bool _isOnline = true;
  
  // Current upload state
  PhotoUploadItem? _currentUpload;
  double _currentProgress = 0.0;

  // Getters
  bool get isProcessing => _isProcessing;
  bool get isOnline => _isOnline;
  PhotoUploadItem? get currentUpload => _currentUpload;
  double get currentProgress => _currentProgress;

  List<PhotoUploadItem> get pendingUploads {
    if (_box == null) return [];
    return _box!.values
        .map((e) => PhotoUploadItem.fromJson(Map<String, dynamic>.from(e)))
        .where((item) => item.status == PhotoUploadStatus.pending ||
                        item.status == PhotoUploadStatus.failed)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  int get pendingCount => pendingUploads.length;

  /// Initialize the service
  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
    
    // Process any pending uploads if online
    if (_isOnline) {
      _processQueue();
    }
  }

  /// Clean up resources
  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _box?.close();
    super.dispose();
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = !result.contains(ConnectivityResult.none);
    
    notifyListeners();

    // Start processing queue when coming back online
    if (!wasOnline && _isOnline) {
      debugPrint('[PhotoUploadService] Back online - processing queue');
      _processQueue();
    }
  }

  /// Queue a photo for upload (AC7)
  Future<String> queuePhoto({
    required String localPath,
    required int listingId,
    required String cropType,
    required Map<String, dynamic> metadata,
  }) async {
    final id = '${listingId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Copy photo to app directory for persistence
    final persistedPath = await _persistPhoto(localPath, id);
    
    final item = PhotoUploadItem(
      id: id,
      localPath: persistedPath,
      listingId: listingId,
      cropType: cropType,
      metadata: metadata,
    );

    await _box?.put(id, item.toJson());
    notifyListeners();

    // Start processing if online
    if (_isOnline && !_isProcessing) {
      _processQueue();
    }

    return id;
  }

  Future<String> _persistPhoto(String sourcePath, String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path_lib.join(appDir.path, 'pending_photos'));
    
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final destPath = path_lib.join(photosDir.path, '$id.jpg');
    await File(sourcePath).copy(destPath);
    
    return destPath;
  }

  /// Process the upload queue (AC7)
  Future<void> _processQueue() async {
    if (_isProcessing || !_isOnline) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final items = pendingUploads;
      
      for (final item in items) {
        if (!_isOnline) break;
        
        await _uploadItem(item);
      }
    } finally {
      _isProcessing = false;
      _currentUpload = null;
      _currentProgress = 0.0;
      notifyListeners();
    }
  }

  /// Upload a single item (AC5)
  Future<void> _uploadItem(PhotoUploadItem item) async {
    _currentUpload = item;
    _currentProgress = 0.0;
    notifyListeners();

    try {
      // Update status to uploading
      item.status = PhotoUploadStatus.uploading;
      await _saveItem(item);
      notifyListeners();

      // Step 1: Get presigned URL (Phase 2 - actual API call)
      // For now, simulate the flow
      await _simulateProgress(0.0, 0.2);
      
      // Step 2: Upload to S3 (Phase 2 - actual HTTP PUT)
      await _simulateProgress(0.2, 0.8);

      // Step 3: Confirm upload (Phase 2 - actual API call)
      await _simulateProgress(0.8, 1.0);

      // Success!
      item.status = PhotoUploadStatus.completed;
      item.uploadedAt = DateTime.now();
      await _saveItem(item);

      // Clean up local file
      await _cleanupLocalFile(item.localPath);

      debugPrint('[PhotoUploadService] Upload completed: ${item.id}');
      
    } catch (e) {
      debugPrint('[PhotoUploadService] Upload failed: ${item.id} - $e');
      
      item.retryCount++;
      item.errorMessage = e.toString();
      
      if (item.retryCount >= _maxRetries) {
        item.status = PhotoUploadStatus.failed;
      } else {
        item.status = PhotoUploadStatus.pending;
        // Will retry on next queue processing
      }
      
      await _saveItem(item);
    }

    notifyListeners();
  }

  Future<void> _simulateProgress(double start, double end) async {
    const steps = 10;
    final stepDuration = const Duration(milliseconds: 100);
    final increment = (end - start) / steps;

    for (int i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      _currentProgress = start + (increment * (i + 1));
      notifyListeners();
    }
  }

  Future<void> _saveItem(PhotoUploadItem item) async {
    await _box?.put(item.id, item.toJson());
  }

  Future<void> _cleanupLocalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('[PhotoUploadService] Cleanup failed: $e');
    }
  }

  /// Retry a failed upload
  Future<void> retryUpload(String id) async {
    final json = _box?.get(id);
    if (json == null) return;

    final item = PhotoUploadItem.fromJson(Map<String, dynamic>.from(json));
    item.status = PhotoUploadStatus.pending;
    item.retryCount = 0;
    item.errorMessage = null;
    
    await _saveItem(item);
    notifyListeners();

    if (_isOnline && !_isProcessing) {
      _processQueue();
    }
  }

  /// Remove an item from the queue
  Future<void> removeFromQueue(String id) async {
    final json = _box?.get(id);
    if (json != null) {
      final item = PhotoUploadItem.fromJson(Map<String, dynamic>.from(json));
      await _cleanupLocalFile(item.localPath);
    }
    
    await _box?.delete(id);
    notifyListeners();
  }

  /// Clear completed uploads
  Future<void> clearCompleted() async {
    if (_box == null) return;

    final toRemove = <String>[];
    for (final key in _box!.keys) {
      final json = _box!.get(key);
      if (json != null) {
        final item = PhotoUploadItem.fromJson(Map<String, dynamic>.from(json));
        if (item.status == PhotoUploadStatus.completed) {
          toRemove.add(key as String);
        }
      }
    }

    for (final id in toRemove) {
      await _box!.delete(id);
    }
    
    notifyListeners();
  }

  /// Force sync all pending uploads
  Future<void> syncNow() async {
    if (!_isOnline) {
      throw Exception('Cannot sync while offline');
    }
    await _processQueue();
  }
}

// ============================================================================
// Singleton Instance
// ============================================================================

final photoUploadService = PhotoUploadService();
