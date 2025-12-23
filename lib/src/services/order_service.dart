import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order_models.dart';

/// Order Service - Story 3.6 (AC: 1, 2, 5)
///
/// Service layer for order operations:
/// - Fetch farmer's orders with filters
/// - Get order details with timeline
/// - Handle real-time order updates
class OrderService {
  // Singleton pattern
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Base URL - will be configured from environment
  final String _baseUrl = 'https://api.cropfresh.app/v1';

  // Cache
  final Map<String, Order> _orderCache = {};
  List<Order>? _activeOrdersCache;
  DateTime? _lastFetch;

  // Stream controller for real-time updates
  final StreamController<Order> _orderUpdateController =
      StreamController<Order>.broadcast();

  /// Stream of order updates for real-time UI refresh
  Stream<Order> get orderUpdates => _orderUpdateController.stream;

  /// Fetch farmer's orders with filter and pagination
  Future<OrdersResponse> getOrders({
    OrderFilter filter = OrderFilter.all,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build query params
      final status = filter == OrderFilter.active
          ? 'active'
          : (filter == OrderFilter.completed ? 'completed' : null);

      // TODO: Replace with actual HTTP call
      // final url = '$_baseUrl/farmers/orders';
      // final response = await http.get(Uri.parse(url).replace(
      //   queryParameters: {
      //     if (status != null) 'status': status,
      //     'page': page.toString(),
      //     'limit': limit.toString(),
      //   },
      // ), headers: _headers);

      // Mock response for development
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockOrders = _generateMockOrders(filter, page);
      
      // Update cache
      for (final order in mockOrders) {
        _orderCache[order.id] = order;
      }
      _lastFetch = DateTime.now();

      return OrdersResponse(
        orders: mockOrders,
        page: page,
        limit: limit,
        total: 25, // Mock total
      );
    } catch (e) {
      debugPrint('OrderService.getOrders error: $e');
      rethrow;
    }
  }

  /// Fetch single order with full details and timeline
  Future<Order> getOrderDetails(String orderId) async {
    try {
      // Check cache first
      if (_orderCache.containsKey(orderId)) {
        final cached = _orderCache[orderId]!;
        // Use cache if less than 1 minute old
        if (_lastFetch != null &&
            DateTime.now().difference(_lastFetch!).inMinutes < 1) {
          return cached;
        }
      }

      // TODO: Replace with actual HTTP call
      // final url = '$_baseUrl/farmers/orders/$orderId';
      // final response = await http.get(Uri.parse(url), headers: _headers);

      // Mock response
      await Future.delayed(const Duration(milliseconds: 200));
      
      final order = Order.mock(status: OrderStatus.inTransit);
      _orderCache[orderId] = order;
      
      return order;
    } catch (e) {
      debugPrint('OrderService.getOrderDetails error: $e');
      rethrow;
    }
  }

  /// Get active order count for badge display
  Future<int> getActiveOrderCount() async {
    if (_activeOrdersCache != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inMinutes < 5) {
      return _activeOrdersCache!.where((o) => o.isActive).length;
    }

    final response = await getOrders(filter: OrderFilter.active, limit: 50);
    _activeOrdersCache = response.orders;
    return response.orders.length;
  }

  /// Handle incoming order status update (from FCM)
  void handleStatusUpdate(Map<String, dynamic> payload) {
    try {
      final orderId = payload['order_id'] as String?;
      final newStatus = payload['status'] as String?;
      
      if (orderId == null || newStatus == null) return;

      // Update cache if order exists
      if (_orderCache.containsKey(orderId)) {
        final existingOrder = _orderCache[orderId]!;
        final updatedOrder = Order(
          id: existingOrder.id,
          listing: existingOrder.listing,
          buyer: existingOrder.buyer,
          status: OrderStatusExtension.fromString(newStatus),
          currentStep: _getStepFromStatus(newStatus),
          totalSteps: existingOrder.totalSteps,
          totalAmount: existingOrder.totalAmount,
          eta: existingOrder.eta,
          delayMinutes: existingOrder.delayMinutes,
          delayReason: existingOrder.delayReason,
          hauler: existingOrder.hauler,
          timeline: existingOrder.timeline,
          upiTransactionId: existingOrder.upiTransactionId,
          createdAt: existingOrder.createdAt,
          updatedAt: DateTime.now(),
        );
        
        _orderCache[orderId] = updatedOrder;
        _orderUpdateController.add(updatedOrder);
      } else {
        // Fetch full order if not in cache
        getOrderDetails(orderId).then((order) {
          _orderUpdateController.add(order);
        });
      }
    } catch (e) {
      debugPrint('OrderService.handleStatusUpdate error: $e');
    }
  }

  /// Clear cache (for pull-to-refresh)
  void clearCache() {
    _orderCache.clear();
    _activeOrdersCache = null;
    _lastFetch = null;
  }

  /// Dispose streams
  void dispose() {
    _orderUpdateController.close();
  }

  // ============================================
  // Private helpers
  // ============================================

  int _getStepFromStatus(String status) {
    return OrderStatusExtension.fromString(status).step;
  }

  List<Order> _generateMockOrders(OrderFilter filter, int page) {
    if (page > 3) return [];
    
    switch (filter) {
      case OrderFilter.active:
        return [
          Order.mock(status: OrderStatus.inTransit),
          Order.mock(status: OrderStatus.atDropPoint),
          Order.mock(status: OrderStatus.pickupScheduled),
          Order.mock(status: OrderStatus.matched),
        ];
      case OrderFilter.completed:
        return [
          Order.mock(status: OrderStatus.paid),
          Order.mock(status: OrderStatus.paid),
        ];
      case OrderFilter.all:
        return [
          Order.mock(status: OrderStatus.inTransit),
          Order.mock(status: OrderStatus.paid),
          Order.mock(status: OrderStatus.atDropPoint),
          Order.mock(status: OrderStatus.paid),
        ];
    }
  }
}
