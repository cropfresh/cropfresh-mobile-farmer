import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_typography.dart';
import '../../models/order_models.dart';
import '../../widgets/order_widgets.dart';

/// My Orders Screen - Story 3.6 (AC: 5)
///
/// Main order list screen with:
/// - Tab filters: Active / Completed / All
/// - Pull-to-refresh
/// - Infinite scroll pagination
/// - Empty states per filter
/// - Navigation to order details
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  OrderFilter _currentFilter = OrderFilter.active;

  // State
  List<Order> _orders = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  // Scroll controller for infinite scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final newFilter = OrderFilter.values[_tabController.index];
    if (newFilter != _currentFilter) {
      setState(() {
        _currentFilter = newFilter;
        _page = 1;
        _hasMore = true;
      });
      _loadOrders();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      final mockOrders = _generateMockOrders();
      
      setState(() {
        _orders = mockOrders;
        _isLoading = false;
        _hasMore = mockOrders.length >= 10;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      _page++;
      
      // Mock: Return empty after page 3
      if (_page > 3) {
        setState(() {
          _isLoadingMore = false;
          _hasMore = false;
        });
        return;
      }

      final moreOrders = _generateMockOrders();
      setState(() {
        _orders.addAll(moreOrders);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  List<Order> _generateMockOrders() {
    // Generate based on filter
    switch (_currentFilter) {
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

  void _navigateToOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(OrderFilter.active),
          _buildOrderList(OrderFilter.completed),
          _buildOrderList(OrderFilter.all),
        ],
      ),
    );
  }

  Widget _buildOrderList(OrderFilter filter) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final filteredOrders = _orders.where((o) {
      switch (filter) {
        case OrderFilter.active:
          return o.isActive;
        case OrderFilter.completed:
          return o.isCompleted;
        case OrderFilter.all:
          return true;
      }
    }).toList();

    if (filteredOrders.isEmpty) {
      return EmptyOrdersState(
        filter: filter,
        onRefresh: _loadOrders,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredOrders.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index == filteredOrders.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final order = filteredOrders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: OrderCard(
              order: order,
              onTap: () => _navigateToOrderDetails(order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load orders',
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order Details Screen - Story 3.6 (AC: 1, 3, 6)
///
/// Full order details with:
/// - 7-stage status timeline
/// - Hauler contact card (In Transit)
/// - Delay indicator
/// - TTS voice announcement
/// - Download receipt button (Paid)
class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _ttsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Auto-announce status via TTS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceStatus();
    });
  }

  Future<void> _announceStatus() async {
    if (!_ttsEnabled) return;
    // TODO: Integrate with flutter_tts service
    // final tts = context.read<TtsService>();
    // await tts.speak(widget.order.ttsAnnouncement);
    debugPrint('TTS: ${widget.order.ttsAnnouncement}');
  }

  void _callHauler() async {
    final hauler = widget.order.hauler;
    if (hauler == null) return;
    // TODO: Launch phone dialer
    // await launchUrl(Uri.parse('tel:${hauler.phone}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${hauler.name}...')),
    );
  }

  void _downloadReceipt() {
    // TODO: Download PDF receipt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading receipt...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          // TTS toggle
          IconButton(
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (_ttsEnabled) _announceStatus();
            },
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              semanticLabel: _ttsEnabled ? 'Mute voice' : 'Enable voice',
            ),
            tooltip: _ttsEnabled ? 'Mute voice' : 'Enable voice',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            _buildOrderSummary(order, colorScheme),
            const SizedBox(height: AppSpacing.sectionGap),

            // Delay indicator (if applicable)
            if (order.hasDelay) ...[
              DelayIndicator(
                delayMinutes: order.delayMinutes!,
                reason: order.delayReason,
                updatedEta: order.eta,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Hauler contact card (In Transit)
            if (order.status == OrderStatus.inTransit && order.hauler != null) ...[
              HaulerContactCard(
                hauler: order.hauler!,
                eta: order.eta,
                onCall: _callHauler,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Section header
            Text(
              'Order Timeline',
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Status timeline
            StatusTimeline(
              events: order.timeline.isNotEmpty 
                  ? order.timeline 
                  : _generateFallbackTimeline(order.status),
              currentStatus: order.status,
              onStepTap: () {
                // TODO: Show step details modal
              },
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // Download receipt button (for completed orders)
            if (order.isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: AppSpacing.recommendedTouchTarget,
                child: OutlinedButton.icon(
                  onPressed: _downloadReceipt,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Receipt'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                    ),
                  ),
                ),
              ),
            ],

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
          ],
        ),
      ),
    );
  }


  /// Generate fallback timeline events based on current status
  List<TimelineEvent> _generateFallbackTimeline(OrderStatus currentStatus) {
    final now = DateTime.now();
    return OrderStatus.values.map((status) {
      final isCompleted = status.step < currentStatus.step;
      final isActive = status == currentStatus;
      
      return TimelineEvent(
        step: status.step,
        status: status,
        label: status.label,
        completed: isCompleted,
        active: isActive,
        timestamp: isCompleted || isActive
            ? now.subtract(Duration(hours: (7 - status.step) * 2))
            : null,
      );
    }).toList();
  }

  Widget _buildOrderSummary(Order order, ColorScheme colorScheme) {
    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop info row
            Row(
              children: [
                // Crop emoji
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      order.listing.cropEmoji,
                      style: const TextStyle(fontSize: 32),
                      semanticsLabel: order.listing.cropType,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Crop details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.listing.formattedQuantity} ${order.listing.cropType}',
                        style: AppTypography.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.buyer.displayName,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: colorScheme.outlineVariant),
            const SizedBox(height: AppSpacing.md),

            // Status and amount row
            Row(
              children: [
                StatusBadge(status: order.status),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: order.isCompleted 
                        ? AppColors.successGradient 
                        : AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.formattedTotalExact,
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // ETA display (for active orders)
            if (order.isActive && order.eta != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Estimated: ${order.formattedEta}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
