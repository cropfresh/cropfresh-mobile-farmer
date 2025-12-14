import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Listing status enum
enum ListingStatus {
  draft,
  active,
  matched,
  completed,
  expired,
}

/// Listing model
class CropListing {
  final String id;
  final String produceId;
  final String produceName;
  final String produceEmoji;
  final double quantity;
  final String unit;
  final String? photoPath;
  final String qualityGrade;
  final String entryMode;
  final ListingStatus status;
  final DateTime createdAt;
  final double? estimatedPrice;

  CropListing({
    required this.id,
    required this.produceId,
    required this.produceName,
    required this.produceEmoji,
    required this.quantity,
    required this.unit,
    this.photoPath,
    required this.qualityGrade,
    required this.entryMode,
    required this.status,
    required this.createdAt,
    this.estimatedPrice,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'produceId': produceId,
    'produceName': produceName,
    'produceEmoji': produceEmoji,
    'quantity': quantity,
    'unit': unit,
    'photoPath': photoPath,
    'qualityGrade': qualityGrade,
    'entryMode': entryMode,
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'estimatedPrice': estimatedPrice,
  };

  factory CropListing.fromJson(Map<String, dynamic> json) => CropListing(
    id: json['id'],
    produceId: json['produceId'],
    produceName: json['produceName'],
    produceEmoji: json['produceEmoji'],
    quantity: json['quantity'].toDouble(),
    unit: json['unit'],
    photoPath: json['photoPath'],
    qualityGrade: json['qualityGrade'],
    entryMode: json['entryMode'],
    status: ListingStatus.values[json['status']],
    createdAt: DateTime.parse(json['createdAt']),
    estimatedPrice: json['estimatedPrice']?.toDouble(),
  );
}

/// Provider for managing crop listings
class ListingsProvider extends ChangeNotifier {
  static const String _storageKey = 'crop_listings';
  
  List<CropListing> _listings = [];
  bool _isLoading = false;

  List<CropListing> get listings => _listings;
  List<CropListing> get activeListings => 
      _listings.where((l) => l.status == ListingStatus.active).toList();
  List<CropListing> get draftListings => 
      _listings.where((l) => l.status == ListingStatus.draft).toList();
  bool get isLoading => _isLoading;
  bool get hasListings => _listings.isNotEmpty;

  /// Load listings from local storage
  Future<void> loadListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      
      if (jsonStr != null) {
        final List<dynamic> jsonList = json.decode(jsonStr);
        _listings = jsonList.map((j) => CropListing.fromJson(j)).toList();
        // Sort by created date, newest first
        _listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      debugPrint('Error loading listings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Save listings to local storage
  Future<void> _saveListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_listings.map((l) => l.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving listings: $e');
    }
  }

  /// Add a new listing
  Future<void> addListing(CropListing listing) async {
    _listings.insert(0, listing);
    await _saveListings();
    notifyListeners();
  }

  /// Create a new listing from parameters
  Future<CropListing> createListing({
    required String produceId,
    required String produceName,
    required String produceEmoji,
    required double quantity,
    required String unit,
    String? photoPath,
    required String qualityGrade,
    required String entryMode,
    double? estimatedPrice,
  }) async {
    final listing = CropListing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      produceId: produceId,
      produceName: produceName,
      produceEmoji: produceEmoji,
      quantity: quantity,
      unit: unit,
      photoPath: photoPath,
      qualityGrade: qualityGrade,
      entryMode: entryMode,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
      estimatedPrice: estimatedPrice,
    );

    await addListing(listing);
    return listing;
  }

  /// Update listing status
  Future<void> updateListingStatus(String listingId, ListingStatus status) async {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final old = _listings[index];
      _listings[index] = CropListing(
        id: old.id,
        produceId: old.produceId,
        produceName: old.produceName,
        produceEmoji: old.produceEmoji,
        quantity: old.quantity,
        unit: old.unit,
        photoPath: old.photoPath,
        qualityGrade: old.qualityGrade,
        entryMode: old.entryMode,
        status: status,
        createdAt: old.createdAt,
        estimatedPrice: old.estimatedPrice,
      );
      await _saveListings();
      notifyListeners();
    }
  }

  /// Delete a listing
  Future<void> deleteListing(String listingId) async {
    _listings.removeWhere((l) => l.id == listingId);
    await _saveListings();
    notifyListeners();
  }

  /// Get listing by id
  CropListing? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
