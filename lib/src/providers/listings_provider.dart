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
  cancelled, // Added for Story 3.9
}

/// Cancellation reason enum (Story 3.9)
enum CancellationReason {
  soldElsewhere,
  qualityChanged,
  changedMind,
  other,
}

/// Extension methods for CancellationReason
extension CancellationReasonExt on CancellationReason {
  String get label {
    switch (this) {
      case CancellationReason.soldElsewhere:
        return 'Sold elsewhere';
      case CancellationReason.qualityChanged:
        return 'Quality changed';
      case CancellationReason.changedMind:
        return 'Changed my mind';
      case CancellationReason.other:
        return 'Other';
    }
  }

  String get apiValue {
    switch (this) {
      case CancellationReason.soldElsewhere:
        return 'SOLD_ELSEWHERE';
      case CancellationReason.qualityChanged:
        return 'QUALITY_CHANGED';
      case CancellationReason.changedMind:
        return 'CHANGED_MIND';
      case CancellationReason.other:
        return 'OTHER';
    }
  }
}

/// Listing model
class CropListing {
  final String id;
  final String produceId;
  final String produceName;
  final String produceEmoji;
  final double quantity;
  final double originalQuantity; // Track original for validation
  final String unit;
  final String? photoPath;
  final String qualityGrade;
  final String entryMode;
  final ListingStatus status;
  final DateTime createdAt;
  final double? estimatedPrice;
  final DateTime? cancelledAt;
  final CancellationReason? cancellationReason;

  CropListing({
    required this.id,
    required this.produceId,
    required this.produceName,
    required this.produceEmoji,
    required this.quantity,
    double? originalQuantity,
    required this.unit,
    this.photoPath,
    required this.qualityGrade,
    required this.entryMode,
    required this.status,
    required this.createdAt,
    this.estimatedPrice,
    this.cancelledAt,
    this.cancellationReason,
  }) : originalQuantity = originalQuantity ?? quantity;

  /// Create a copy with updated fields
  CropListing copyWith({
    String? id,
    String? produceId,
    String? produceName,
    String? produceEmoji,
    double? quantity,
    double? originalQuantity,
    String? unit,
    String? photoPath,
    String? qualityGrade,
    String? entryMode,
    ListingStatus? status,
    DateTime? createdAt,
    double? estimatedPrice,
    DateTime? cancelledAt,
    CancellationReason? cancellationReason,
  }) {
    return CropListing(
      id: id ?? this.id,
      produceId: produceId ?? this.produceId,
      produceName: produceName ?? this.produceName,
      produceEmoji: produceEmoji ?? this.produceEmoji,
      quantity: quantity ?? this.quantity,
      originalQuantity: originalQuantity ?? this.originalQuantity,
      unit: unit ?? this.unit,
      photoPath: photoPath ?? this.photoPath,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      entryMode: entryMode ?? this.entryMode,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'produceId': produceId,
    'produceName': produceName,
    'produceEmoji': produceEmoji,
    'quantity': quantity,
    'originalQuantity': originalQuantity,
    'unit': unit,
    'photoPath': photoPath,
    'qualityGrade': qualityGrade,
    'entryMode': entryMode,
    'status': status.index,
    'createdAt': createdAt.toIso8601String(),
    'estimatedPrice': estimatedPrice,
    'cancelledAt': cancelledAt?.toIso8601String(),
    'cancellationReason': cancellationReason?.index,
  };

  factory CropListing.fromJson(Map<String, dynamic> json) => CropListing(
    id: json['id'],
    produceId: json['produceId'],
    produceName: json['produceName'],
    produceEmoji: json['produceEmoji'],
    quantity: json['quantity'].toDouble(),
    originalQuantity: json['originalQuantity']?.toDouble(),
    unit: json['unit'],
    photoPath: json['photoPath'],
    qualityGrade: json['qualityGrade'],
    entryMode: json['entryMode'],
    status: ListingStatus.values[json['status']],
    createdAt: DateTime.parse(json['createdAt']),
    estimatedPrice: json['estimatedPrice']?.toDouble(),
    cancelledAt: json['cancelledAt'] != null 
        ? DateTime.parse(json['cancelledAt']) 
        : null,
    cancellationReason: json['cancellationReason'] != null
        ? CancellationReason.values[json['cancellationReason']]
        : null,
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
      
      // If no listings, load mock data for demo
      if (_listings.isEmpty) {
        await loadMockListings();
      }
    } catch (e) {
      debugPrint('Error loading listings: $e');
      // Load mock data on error for demo
      await loadMockListings();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load mock listings for testing/demo purposes
  Future<void> loadMockListings() async {
    _listings = [
      CropListing(
        id: '1',
        produceId: 'tomato',
        produceName: 'Tomatoes',
        produceEmoji: '🍅',
        quantity: 50,
        unit: 'kg',
        qualityGrade: 'A',
        entryMode: 'voice',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        estimatedPrice: 1500,
      ),
      CropListing(
        id: '2',
        produceId: 'onion',
        produceName: 'Onions',
        produceEmoji: '🧅',
        quantity: 100,
        unit: 'kg',
        qualityGrade: 'B',
        entryMode: 'voice',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        estimatedPrice: 2800,
      ),
      CropListing(
        id: '3',
        produceId: 'rice',
        produceName: 'Rice (Basmati)',
        produceEmoji: '🌾',
        quantity: 200,
        unit: 'kg',
        qualityGrade: 'A',
        entryMode: 'manual',
        status: ListingStatus.matched,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        estimatedPrice: 8400,
      ),
      CropListing(
        id: '4',
        produceId: 'potato',
        produceName: 'Potatoes',
        produceEmoji: '🥔',
        quantity: 75,
        unit: 'kg',
        qualityGrade: 'B',
        entryMode: 'voice',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        estimatedPrice: 1875,
      ),
      CropListing(
        id: '5',
        produceId: 'carrot',
        produceName: 'Carrots',
        produceEmoji: '🥕',
        quantity: 30,
        unit: 'kg',
        qualityGrade: 'A',
        entryMode: 'voice',
        status: ListingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        estimatedPrice: 900,
      ),
    ];
    await _saveListings();
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
      _listings[index] = _listings[index].copyWith(status: status);
      await _saveListings();
      notifyListeners();
    }
  }

  /// Update listing details (Story 3.9 - AC2-6)
  /// 
  /// Updates quantity, photo, and/or drop-off time.
  /// Validates quantity <= originalQuantity.
  Future<CropListing> updateListing({
    required String listingId,
    double? quantity,
    String? photoPath,
    String? qualityGrade,
    double? estimatedPrice,
    String? dropoffWindowId,
  }) async {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index == -1) {
      throw Exception('Listing not found');
    }

    final listing = _listings[index];
    
    // Validate status
    if (listing.status != ListingStatus.active) {
      throw Exception('Can only update active listings');
    }

    // Validate quantity
    if (quantity != null) {
      if (quantity <= 0) {
        throw Exception('Quantity must be greater than 0');
      }
      if (quantity > listing.originalQuantity) {
        throw Exception('Cannot increase quantity beyond ${listing.originalQuantity}');
      }
    }

    // Calculate new estimated price if quantity changed
    double? newEstimatedPrice = estimatedPrice;
    if (quantity != null && listing.estimatedPrice != null) {
      final pricePerUnit = listing.estimatedPrice! / listing.quantity;
      newEstimatedPrice = pricePerUnit * quantity;
    }

    // Update listing
    final updatedListing = listing.copyWith(
      quantity: quantity ?? listing.quantity,
      photoPath: photoPath ?? listing.photoPath,
      qualityGrade: qualityGrade ?? listing.qualityGrade,
      estimatedPrice: newEstimatedPrice ?? listing.estimatedPrice,
    );

    _listings[index] = updatedListing;
    await _saveListings();
    notifyListeners();

    // TODO: Call backend API
    // await _api.updateListing(listingId, quantity, photoPath, dropoffWindowId);

    return updatedListing;
  }

  /// Cancel a listing (Story 3.9 - AC7-9)
  /// 
  /// Validates cancellation is allowed and records reason.
  Future<void> cancelListing(String listingId, CancellationReason? reason) async {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index == -1) {
      throw Exception('Listing not found');
    }

    final listing = _listings[index];
    
    // Validate status - cannot cancel if already matched
    if (listing.status == ListingStatus.matched) {
      throw Exception('Cannot cancel a matched listing');
    }
    
    if (listing.status != ListingStatus.active) {
      throw Exception('Can only cancel active listings');
    }

    // TODO: Validate 2-hour drop-off time restriction
    // if (listing.dropoffTime != null) {
    //   final timeUntilDropoff = listing.dropoffTime!.difference(DateTime.now());
    //   if (timeUntilDropoff.inHours < 2) {
    //     throw Exception('Cannot cancel within 2 hours of drop-off');
    //   }
    // }

    // Update listing status to cancelled
    _listings[index] = listing.copyWith(
      status: ListingStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancellationReason: reason,
    );

    await _saveListings();
    notifyListeners();

    // TODO: Call backend API
    // await _api.cancelListing(listingId, reason?.apiValue);
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

