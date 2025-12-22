// Drop Point Models - Story 3.4
// Models for village drop point assignment and delivery tracking.

/// Geographic location with lat/lng coordinates
class GeoLocation {
  final double latitude;
  final double longitude;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: (json['lat'] ?? json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['lng'] ?? json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// Drop point assignment status
enum AssignmentStatus {
  assigned,
  enRoute,
  arrived,
  completed,
  cancelled,
  reassigned,
}

extension AssignmentStatusExtension on AssignmentStatus {
  String get label {
    switch (this) {
      case AssignmentStatus.assigned:
        return 'Assigned';
      case AssignmentStatus.enRoute:
        return 'On the way';
      case AssignmentStatus.arrived:
        return 'Arrived';
      case AssignmentStatus.completed:
        return 'Completed';
      case AssignmentStatus.cancelled:
        return 'Cancelled';
      case AssignmentStatus.reassigned:
        return 'Reassigned';
    }
  }

  String get icon {
    switch (this) {
      case AssignmentStatus.assigned:
        return 'assignment_turned_in';
      case AssignmentStatus.enRoute:
        return 'local_shipping';
      case AssignmentStatus.arrived:
        return 'place';
      case AssignmentStatus.completed:
        return 'check_circle';
      case AssignmentStatus.cancelled:
        return 'cancel';
      case AssignmentStatus.reassigned:
        return 'swap_horiz';
    }
  }
}

/// Drop point location for produce delivery
class DropPoint {
  final String id;
  final String name;
  final String address;
  final GeoLocation location;
  final double distanceKm;
  final bool isOpen;

  const DropPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.distanceKm,
    this.isOpen = true,
  });

  factory DropPoint.fromJson(Map<String, dynamic> json) {
    return DropPoint(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      location: GeoLocation.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['is_open'] as bool? ?? true,
    );
  }

  /// Create mock drop point for development
  factory DropPoint.mock() {
    return const DropPoint(
      id: 'dp-001',
      name: 'Kolar Main Drop Point',
      address: 'Near KSRTC Bus Stand, Station Road, Kolar, Karnataka 563101',
      location: GeoLocation(latitude: 13.1378, longitude: 78.1300),
      distanceKm: 3.2,
      isOpen: true,
    );
  }
}

/// Pickup time window for drop-off
class PickupWindow {
  final DateTime start;
  final DateTime end;

  const PickupWindow({
    required this.start,
    required this.end,
  });

  factory PickupWindow.fromJson(Map<String, dynamic> json) {
    return PickupWindow(
      start: DateTime.tryParse(json['start'] as String? ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Format the window as "7-9 AM" style
  String get formattedWindow {
    final startHour = start.hour;
    final endHour = end.hour;
    final period = startHour < 12 ? 'AM' : 'PM';
    final displayStart = startHour > 12 ? startHour - 12 : startHour;
    final displayEnd = endHour > 12 ? endHour - 12 : endHour;
    return '$displayStart-$displayEnd $period';
  }

  /// Format the date as "Tomorrow" or "Dec 23"
  String get formattedDate {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final isToday = start.day == now.day && start.month == now.month;
    final isTomorrow = start.day == tomorrow.day && start.month == tomorrow.month;

    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[start.month - 1]} ${start.day}';
  }

  /// Get hours until drop-off
  Duration get timeUntilStart => start.difference(DateTime.now());

  /// Format countdown as "18 hours" or "2 days"
  String get countdownText {
    final diff = timeUntilStart;
    if (diff.isNegative) return 'Now';
    if (diff.inDays > 0) return '${diff.inDays} days';
    if (diff.inHours > 0) return '${diff.inHours} hours';
    return '${diff.inMinutes} minutes';
  }

  /// Create mock window for development
  factory PickupWindow.mock() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return PickupWindow(
      start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 7, 0),
      end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
    );
  }
}

/// Complete drop point assignment for a listing
class DropPointAssignment {
  final String assignmentId;
  final int listingId;
  final DropPoint dropPoint;
  final PickupWindow pickupWindow;
  final int cratesNeeded;
  final AssignmentStatus status;
  final String? changeReason;
  final String? previousDropPointName;

  const DropPointAssignment({
    required this.assignmentId,
    required this.listingId,
    required this.dropPoint,
    required this.pickupWindow,
    required this.cratesNeeded,
    this.status = AssignmentStatus.assigned,
    this.changeReason,
    this.previousDropPointName,
  });

  factory DropPointAssignment.fromJson(Map<String, dynamic> json) {
    return DropPointAssignment(
      assignmentId: json['assignment_id'] as String? ?? '',
      listingId: json['listing_id'] as int? ?? 0,
      dropPoint: DropPoint.fromJson(json['drop_point'] as Map<String, dynamic>? ?? {}),
      pickupWindow: PickupWindow.fromJson(json['pickup_window'] as Map<String, dynamic>? ?? {}),
      cratesNeeded: json['crates_needed'] as int? ?? 1,
      status: _parseStatus(json['status'] as String?),
      changeReason: json['change_reason'] as String?,
      previousDropPointName: json['previous_drop_point_name'] as String?,
    );
  }

  static AssignmentStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ASSIGNED':
        return AssignmentStatus.assigned;
      case 'EN_ROUTE':
        return AssignmentStatus.enRoute;
      case 'ARRIVED':
        return AssignmentStatus.arrived;
      case 'COMPLETED':
        return AssignmentStatus.completed;
      case 'CANCELLED':
        return AssignmentStatus.cancelled;
      case 'REASSIGNED':
        return AssignmentStatus.reassigned;
      default:
        return AssignmentStatus.assigned;
    }
  }

  /// Create mock assignment for development
  factory DropPointAssignment.mock({int? listingId, double? quantityKg}) {
    final qty = quantityKg ?? 50.0;
    return DropPointAssignment(
      assignmentId: 'assign-001',
      listingId: listingId ?? 1,
      dropPoint: DropPoint.mock(),
      pickupWindow: PickupWindow.mock(),
      cratesNeeded: (qty / 50).ceil(), // 1 crate per 50kg
      status: AssignmentStatus.assigned,
    );
  }

  /// Check if this is a reassignment
  bool get isReassigned =>
      status == AssignmentStatus.reassigned && previousDropPointName != null;
}

/// Upcoming delivery for dashboard widget
class UpcomingDelivery {
  final DropPointAssignment assignment;
  final String cropName;
  final String cropEmoji;
  final double quantityKg;
  final double? pricePerKg;

  const UpcomingDelivery({
    required this.assignment,
    required this.cropName,
    required this.cropEmoji,
    required this.quantityKg,
    this.pricePerKg,
  });

  factory UpcomingDelivery.mock() {
    return UpcomingDelivery(
      assignment: DropPointAssignment.mock(),
      cropName: 'Tomatoes',
      cropEmoji: '🍅',
      quantityKg: 50.0,
      pricePerKg: 36.0,
    );
  }
}
