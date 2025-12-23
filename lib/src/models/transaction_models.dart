/// Transaction Models - Story 3.7
///
/// Models for farmer transaction history, earnings, and receipts.
/// Follows Material Design 3 principles with Voice-First support.

import 'package:intl/intl.dart';

/// Transaction status for filtering
enum TransactionStatus {
  completed,
  pending,
  all,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.all:
        return 'All';
    }
  }

  String get apiValue {
    switch (this) {
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.all:
        return 'all';
    }
  }

  static TransactionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'completed':
        return TransactionStatus.completed;
      case 'pending':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.all;
    }
  }
}

/// Sort options for transaction list
enum TransactionSortBy {
  date,
  amount,
  crop,
}

extension TransactionSortByExtension on TransactionSortBy {
  String get label {
    switch (this) {
      case TransactionSortBy.date:
        return 'Date';
      case TransactionSortBy.amount:
        return 'Amount';
      case TransactionSortBy.crop:
        return 'Crop';
    }
  }

  String get apiValue {
    switch (this) {
      case TransactionSortBy.date:
        return 'date';
      case TransactionSortBy.amount:
        return 'amount';
      case TransactionSortBy.crop:
        return 'crop';
    }
  }
}

/// Earnings summary for dashboard (AC1)
class EarningsSummary {
  final double total;
  final double thisMonth;
  final double pending;
  final int totalOrderCount;
  final int thisMonthOrderCount;
  final int newSinceLastVisit;
  final String currency;

  const EarningsSummary({
    required this.total,
    required this.thisMonth,
    required this.pending,
    required this.totalOrderCount,
    required this.thisMonthOrderCount,
    this.newSinceLastVisit = 0,
    this.currency = 'INR',
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      thisMonth: (json['this_month'] as num?)?.toDouble() ?? 0.0,
      pending: (json['pending'] as num?)?.toDouble() ?? 0.0,
      totalOrderCount: json['total_order_count'] as int? ?? 0,
      thisMonthOrderCount: json['this_month_order_count'] as int? ?? 0,
      newSinceLastVisit: json['new_since_last_visit'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'this_month': thisMonth,
        'pending': pending,
        'total_order_count': totalOrderCount,
        'this_month_order_count': thisMonthOrderCount,
        'new_since_last_visit': newSinceLastVisit,
        'currency': currency,
      };

  // ============================================
  // Formatted Getters for UI
  // ============================================

  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  String get formattedTotal => _currencyFormat.format(total);
  String get formattedThisMonth => _currencyFormat.format(thisMonth);
  String get formattedPending => _currencyFormat.format(pending);

  /// TTS announcement for voice-first UX (AC6)
  String get ttsAnnouncement {
    final parts = <String>[];
    parts.add('Your total earnings are ${formattedTotal}.');
    if (thisMonth > 0) {
      parts.add('This month you earned ${formattedThisMonth}.');
    }
    if (pending > 0) {
      parts.add('You have ${formattedPending} pending.');
    }
    if (newSinceLastVisit > 0) {
      parts.add('$newSinceLastVisit new transactions since your last visit.');
    }
    return parts.join(' ');
  }

  /// Badge count for navigation
  bool get hasBadge => newSinceLastVisit > 0;

  factory EarningsSummary.mock() {
    return const EarningsSummary(
      total: 45000,
      thisMonth: 8500,
      pending: 1800,
      totalOrderCount: 45,
      thisMonthOrderCount: 8,
      newSinceLastVisit: 3,
      currency: 'INR',
    );
  }

  factory EarningsSummary.empty() {
    return const EarningsSummary(
      total: 0,
      thisMonth: 0,
      pending: 0,
      totalOrderCount: 0,
      thisMonthOrderCount: 0,
      newSinceLastVisit: 0,
    );
  }
}

/// Transaction list item for infinite scroll (AC2)
class TransactionItem {
  final String id;
  final DateTime date;
  final String cropType;
  final String cropIcon;
  final double quantityKg;
  final String buyerType;
  final String buyerCity;
  final double amount;
  final TransactionStatus status;
  final String? qualityGrade;

  const TransactionItem({
    required this.id,
    required this.date,
    required this.cropType,
    required this.cropIcon,
    required this.quantityKg,
    required this.buyerType,
    required this.buyerCity,
    required this.amount,
    required this.status,
    this.qualityGrade,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      cropType: json['crop_type'] as String? ?? '',
      cropIcon: json['crop_icon'] as String? ?? '🌾',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      buyerType: json['buyer_type'] as String? ?? 'Buyer',
      buyerCity: json['buyer_city'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: TransactionStatusExtension.fromString(json['status'] as String?),
      qualityGrade: json['quality_grade'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'crop_type': cropType,
        'crop_icon': cropIcon,
        'quantity_kg': quantityKg,
        'buyer_type': buyerType,
        'buyer_city': buyerCity,
        'amount': amount,
        'status': status.apiValue,
        if (qualityGrade != null) 'quality_grade': qualityGrade,
      };

  // ============================================
  // Formatted Getters
  // ============================================

  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static final _dateFormat = DateFormat('MMM d, yyyy');

  String get formattedAmount => _currencyFormat.format(amount);
  String get formattedDate => _dateFormat.format(date);
  String get formattedQuantity => '${quantityKg.toStringAsFixed(0)} kg';
  String get cropDisplay => '$cropIcon $cropType';
  String get buyerDisplay => '$buyerType in $buyerCity';

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;

  /// TTS announcement for voice-first UX
  String get ttsAnnouncement {
    final statusLabel = isCompleted ? 'paid' : 'pending';
    return '$cropType, $formattedQuantity, $formattedAmount, $statusLabel. '
        '$buyerType in $buyerCity. $formattedDate.';
  }

  /// Semantic label for accessibility
  String get semanticLabel {
    return '$cropType transaction for $formattedQuantity. '
        '$formattedAmount ${status.label}. '
        '$buyerType in $buyerCity. $formattedDate.';
  }

  factory TransactionItem.mock({
    TransactionStatus status = TransactionStatus.completed,
    int index = 0,
  }) {
    final crops = [
      ('🍅', 'Tomato'),
      ('🥔', 'Potato'),
      ('🥕', 'Carrot'),
      ('🌽', 'Corn'),
      ('🧅', 'Onion'),
    ];
    final buyers = ['Restaurant', 'Hotel', 'Wholesaler', 'Retailer'];
    final cities = ['Bangalore', 'Mysore', 'Hubli', 'Mangalore'];

    final crop = crops[index % crops.length];
    return TransactionItem(
      id: 'ORD-2025-${1234 + index}'.padLeft(12, '0'),
      date: DateTime.now().subtract(Duration(days: index)),
      cropType: crop.$2,
      cropIcon: crop.$1,
      quantityKg: (50 + (index * 10)).toDouble(),
      buyerType: buyers[index % buyers.length],
      buyerCity: cities[index % cities.length],
      amount: 1500 + (index * 250).toDouble(),
      status: status,
      qualityGrade: index % 3 == 0 ? 'A' : (index % 3 == 1 ? 'B' : null),
    );
  }
}

/// Payment breakdown for transaction detail (AC4)
class PaymentBreakdown {
  final double baseAmount;
  final double qualityBonus;
  final double platformFee;
  final double netAmount;
  final String upiTxnId;
  final DateTime? paidAt;

  const PaymentBreakdown({
    required this.baseAmount,
    required this.qualityBonus,
    required this.platformFee,
    required this.netAmount,
    required this.upiTxnId,
    this.paidAt,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      baseAmount: (json['base_amount'] as num?)?.toDouble() ?? 0.0,
      qualityBonus: (json['quality_bonus'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      upiTxnId: json['upi_txn_id'] as String? ?? '',
      paidAt: DateTime.tryParse(json['paid_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'base_amount': baseAmount,
        'quality_bonus': qualityBonus,
        'platform_fee': platformFee,
        'net_amount': netAmount,
        'upi_txn_id': upiTxnId,
        if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      };

  // ============================================
  // Formatted Getters
  // ============================================

  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
    locale: 'en_IN',
  );

  String get formattedBaseAmount => _currencyFormat.format(baseAmount);
  String get formattedQualityBonus => qualityBonus >= 0
      ? '+${_currencyFormat.format(qualityBonus)}'
      : _currencyFormat.format(qualityBonus);
  String get formattedPlatformFee => _currencyFormat.format(platformFee);
  String get formattedNetAmount => _currencyFormat.format(netAmount);

  String? get formattedPaidAt {
    if (paidAt == null) return null;
    return DateFormat('MMM d, yyyy h:mm a').format(paidAt!);
  }

  /// TTS announcement for voice-first UX
  String get ttsAnnouncement {
    final parts = <String>[
      'Payment breakdown.',
      'Base amount ${formattedBaseAmount}.',
    ];
    if (qualityBonus != 0) {
      parts.add('Quality bonus ${formattedQualityBonus}.');
    }
    parts.add('Platform fee is zero.');
    parts.add('Net amount received ${formattedNetAmount}.');
    if (formattedPaidAt != null) {
      parts.add('Paid on $formattedPaidAt.');
    }
    return parts.join(' ');
  }

  factory PaymentBreakdown.mock() {
    return PaymentBreakdown(
      baseAmount: 1750,
      qualityBonus: 50,
      platformFee: 0,
      netAmount: 1800,
      upiTxnId: '****ABCD1234',
      paidAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }
}

/// Drop point info for transaction detail
class DropPointInfo {
  final String name;
  final String address;

  const DropPointInfo({required this.name, required this.address});

  factory DropPointInfo.fromJson(Map<String, dynamic> json) {
    return DropPointInfo(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'address': address};

  factory DropPointInfo.mock() {
    return const DropPointInfo(
      name: 'Kolar Village Drop Point',
      address: 'Main Road, Kolar 563101',
    );
  }
}

/// Full transaction details (AC4)
class TransactionDetails {
  final String id;
  final String listingId;
  final String cropType;
  final String cropEmoji;
  final double quantityKg;
  final String? photoUrl;
  final String buyerType;
  final String buyerCity;
  final String? buyerArea;
  final DropPointInfo? dropPoint;
  final String? haulerName;
  final String? haulerPhone;
  final String? haulerVehicle;
  final List<TransactionTimelineEvent> timeline;
  final PaymentBreakdown payment;
  final DateTime createdAt;
  final bool canDownloadReceipt;

  const TransactionDetails({
    required this.id,
    required this.listingId,
    required this.cropType,
    required this.cropEmoji,
    required this.quantityKg,
    this.photoUrl,
    required this.buyerType,
    required this.buyerCity,
    this.buyerArea,
    this.dropPoint,
    this.haulerName,
    this.haulerPhone,
    this.haulerVehicle,
    required this.timeline,
    required this.payment,
    required this.createdAt,
    required this.canDownloadReceipt,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      id: json['id'] as String? ?? '',
      listingId: json['listing']?['id'] as String? ?? '',
      cropType: json['listing']?['crop_type'] as String? ?? '',
      cropEmoji: json['listing']?['crop_emoji'] as String? ?? '🌾',
      quantityKg:
          (json['listing']?['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      photoUrl: json['listing']?['photo_url'] as String?,
      buyerType: json['buyer']?['business_type'] as String? ?? 'Buyer',
      buyerCity: json['buyer']?['city'] as String? ?? '',
      buyerArea: json['buyer']?['area'] as String?,
      dropPoint: json['drop_point'] != null
          ? DropPointInfo.fromJson(json['drop_point'] as Map<String, dynamic>)
          : null,
      haulerName: json['hauler']?['name'] as String?,
      haulerPhone: json['hauler']?['phone'] as String?,
      haulerVehicle: json['hauler']?['vehicle_type'] as String?,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) =>
                  TransactionTimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      payment: PaymentBreakdown.fromJson(
          json['payment'] as Map<String, dynamic>? ?? {}),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      canDownloadReceipt: json['can_download_receipt'] as bool? ?? false,
    );
  }

  // ============================================
  // Formatted Getters
  // ============================================

  String get cropDisplay => '$cropEmoji $cropType';
  String get formattedQuantity => '${quantityKg.toStringAsFixed(0)} kg';
  String get buyerDisplay =>
      buyerArea != null ? '$buyerType in $buyerArea, $buyerCity' : '$buyerType in $buyerCity';

  static final _dateFormat = DateFormat('MMM d, yyyy');
  String get formattedDate => _dateFormat.format(createdAt);

  /// TTS announcement for voice-first UX
  String get ttsAnnouncement {
    return 'Transaction ${id.split('-').last}. '
        '$cropType, $formattedQuantity. '
        '$buyerDisplay. '
        '${payment.formattedNetAmount} received. '
        '${canDownloadReceipt ? 'Receipt available for download.' : 'Receipt no longer available.'}';
  }

  factory TransactionDetails.mock() {
    return TransactionDetails(
      id: 'ORD-2025-001234',
      listingId: 'LST-001234',
      cropType: 'Tomato',
      cropEmoji: '🍅',
      quantityKg: 50,
      buyerType: 'Restaurant',
      buyerCity: 'Bangalore',
      buyerArea: 'Koramangala',
      dropPoint: DropPointInfo.mock(),
      haulerName: 'Raju Kumar',
      haulerPhone: '+919876543210',
      haulerVehicle: 'Tempo',
      timeline: TransactionTimelineEvent.mockTimeline(),
      payment: PaymentBreakdown.mock(),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      canDownloadReceipt: true,
    );
  }
}

/// Timeline event for transaction detail
class TransactionTimelineEvent {
  final int step;
  final String status;
  final String label;
  final bool completed;
  final bool active;
  final DateTime? timestamp;
  final String? note;

  const TransactionTimelineEvent({
    required this.step,
    required this.status,
    required this.label,
    this.completed = false,
    this.active = false,
    this.timestamp,
    this.note,
  });

  factory TransactionTimelineEvent.fromJson(Map<String, dynamic> json) {
    return TransactionTimelineEvent(
      step: json['step'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      label: json['label'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
      note: json['note'] as String?,
    );
  }

  String? get formattedTimestamp {
    if (timestamp == null) return null;
    return DateFormat('MMM d, h:mm a').format(timestamp!);
  }

  static List<TransactionTimelineEvent> mockTimeline() {
    final now = DateTime.now();
    return [
      TransactionTimelineEvent(
        step: 1,
        status: 'LISTED',
        label: 'Listed',
        completed: true,
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      TransactionTimelineEvent(
        step: 2,
        status: 'MATCHED',
        label: 'Matched',
        completed: true,
        timestamp: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      TransactionTimelineEvent(
        step: 3,
        status: 'PICKUP_SCHEDULED',
        label: 'Pickup Scheduled',
        completed: true,
        timestamp: now.subtract(const Duration(days: 1, hours: 20)),
      ),
      TransactionTimelineEvent(
        step: 4,
        status: 'AT_DROP_POINT',
        label: 'At Drop Point',
        completed: true,
        timestamp: now.subtract(const Duration(days: 1, hours: 16)),
      ),
      TransactionTimelineEvent(
        step: 5,
        status: 'IN_TRANSIT',
        label: 'In Transit',
        completed: true,
        timestamp: now.subtract(const Duration(days: 1, hours: 12)),
      ),
      TransactionTimelineEvent(
        step: 6,
        status: 'DELIVERED',
        label: 'Delivered',
        completed: true,
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      TransactionTimelineEvent(
        step: 7,
        status: 'PAID',
        label: 'Payment Received',
        completed: true,
        active: true,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }
}

/// Filter options for transaction list (AC3)
class TransactionFilter {
  final TransactionStatus status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? cropType;
  final TransactionSortBy sortBy;
  final bool ascending;
  final int page;
  final int limit;

  const TransactionFilter({
    this.status = TransactionStatus.all,
    this.fromDate,
    this.toDate,
    this.cropType,
    this.sortBy = TransactionSortBy.date,
    this.ascending = false,
    this.page = 1,
    this.limit = 20,
  });

  TransactionFilter copyWith({
    TransactionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? cropType,
    TransactionSortBy? sortBy,
    bool? ascending,
    int? page,
    int? limit,
  }) {
    return TransactionFilter(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      cropType: cropType ?? this.cropType,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, String> toQueryParams() {
    return {
      'status': status.apiValue,
      if (fromDate != null) 'from': fromDate!.toIso8601String(),
      if (toDate != null) 'to': toDate!.toIso8601String(),
      if (cropType != null) 'crop': cropType!,
      'sort_by': sortBy.apiValue,
      'sort_order': ascending ? 'asc' : 'desc',
      'page': page.toString(),
      'limit': limit.toString(),
    };
  }
}

/// Paginated transactions response
class TransactionsResponse {
  final List<TransactionItem> transactions;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const TransactionsResponse({
    required this.transactions,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory TransactionsResponse.fromJson(Map<String, dynamic> json) {
    return TransactionsResponse(
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 20,
      total: json['pagination']?['total'] as int? ?? 0,
      hasMore: json['pagination']?['has_more'] as bool? ?? false,
    );
  }

  bool get isEmpty => transactions.isEmpty;
  int get nextPage => page + 1;

  factory TransactionsResponse.mock({int count = 10}) {
    return TransactionsResponse(
      transactions: List.generate(
        count,
        (i) => TransactionItem.mock(
          status:
              i % 3 == 0 ? TransactionStatus.pending : TransactionStatus.completed,
          index: i,
        ),
      ),
      page: 1,
      limit: 20,
      total: count,
      hasMore: count >= 20,
    );
  }

  factory TransactionsResponse.empty() {
    return const TransactionsResponse(
      transactions: [],
      page: 1,
      limit: 20,
      total: 0,
      hasMore: false,
    );
  }
}
