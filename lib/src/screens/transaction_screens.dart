import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/transaction_models.dart';
import '../widgets/transaction_widgets.dart';

/// Earnings Dashboard Screen - Story 3.7 (Task 5)
///
/// Main earnings overview with:
/// - EarningsSummaryCard (AC1)
/// - Recent transactions preview (AC2)
/// - Voice announcement support (AC6)
/// - Navigation to full transaction list
///
/// Follows: Material Design 3, Voice-First UX, 48dp touch targets,
/// responsive layout, smooth animations, WCAG 2.2 AA+.

class EarningsDashboardScreen extends StatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  State<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends State<EarningsDashboardScreen>
    with SingleTickerProviderStateMixin {
  // State
  EarningsSummary? _earnings;
  List<TransactionItem> _recentTransactions = [];
  bool _isLoading = true;
  String? _error;

  // TTS for voice-first UX (AC6)
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTts();
    _loadData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _earnings = EarningsSummary.mock();
        _recentTransactions = List.generate(
          5,
          (i) => TransactionItem.mock(
            status: i % 3 == 0
                ? TransactionStatus.pending
                : TransactionStatus.completed,
            index: i,
          ),
        );
        _isLoading = false;
      });

      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = 'Failed to load earnings. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _speakEarnings() async {
    if (_earnings == null) return;

    setState(() => _isSpeaking = true);
    await _tts.speak(_earnings!.ttsAnnouncement);
  }

  void _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  void _navigateToTransactionList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionListScreen(),
      ),
    );
  }

  void _navigateToTransactionDetails(TransactionItem transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          transactionId: transaction.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings'),
        centerTitle: true,
        actions: [
          // Voice toggle button (AC6)
          IconButton(
            onPressed: _isSpeaking ? _stopSpeaking : _speakEarnings,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop reading' : 'Read earnings aloud',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Loading earnings...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error!),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Earnings summary card (AC1)
            if (_earnings != null)
              EarningsSummaryCard(
                earnings: _earnings!,
                onTap: _navigateToTransactionList,
                onVoiceRead: _speakEarnings,
              ),

            const SizedBox(height: AppSpacing.xl),

            // Recent transactions header
            Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _navigateToTransactionList,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Recent transactions list (AC2)
            if (_recentTransactions.isEmpty)
              const EmptyTransactionsState(
                title: 'No transactions yet',
                message: 'Complete your first sale to see transactions here.',
              )
            else
              ...List.generate(
                _recentTransactions.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: TransactionCard(
                    transaction: _recentTransactions[i],
                    onTap: () => _navigateToTransactionDetails(
                      _recentTransactions[i],
                    ),
                  ),
                ),
              ),

            // Bottom padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

/// Transaction List Screen - Story 3.7 (Task 6)
///
/// Full paginated transaction list with:
/// - Infinite scroll (AC2)
/// - Filters: status, date, crop (AC3)
/// - Pull to refresh
/// - Navigation to details

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  // State
  List<TransactionItem> _transactions = [];
  TransactionFilter _filter = const TransactionFilter();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  // Scroll controller for infinite scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTransactions();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));

      final response = TransactionsResponse.mock(count: 15);
      setState(() {
        _transactions = response.transactions;
        _hasMore = response.hasMore;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load transactions.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));

      final response = TransactionsResponse.mock(count: 10);
      setState(() {
        _transactions.addAll(response.transactions);
        _hasMore = _transactions.length < 50; // Mock limit
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onFilterChanged(TransactionFilter newFilter) {
    setState(() => _filter = newFilter);
    _loadTransactions();
  }

  void _navigateToDetails(TransactionItem transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(
          transactionId: transaction.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter bar (AC3)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: TransactionFilterBar(
              filter: _filter,
              onFilterChanged: _onFilterChanged,
            ),
          ),

          // Transaction list
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error!),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const EmptyTransactionsState(
        title: 'No transactions found',
        message: 'Try adjusting your filters or check back later.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _transactions.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _transactions.length) {
            // Loading more indicator
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final transaction = _transactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: TransactionCard(
              transaction: transaction,
              onTap: () => _navigateToDetails(transaction),
            ),
          );
        },
      ),
    );
  }
}

/// Transaction Detail Screen - Story 3.7 (Task 7)
///
/// Full transaction details with:
/// - Timeline display (AC4)
/// - Payment breakdown (AC4)
/// - Receipt download (AC5)
/// - Voice announcement (AC6)

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionDetails? _details;
  bool _isLoading = true;
  bool _isDownloadingReceipt = false;
  String? _error;

  // TTS for voice-first UX (AC6)
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _loadDetails();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _details = TransactionDetails.mock();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load transaction details.';
        _isLoading = false;
      });
    }
  }

  Future<void> _speakDetails() async {
    if (_details == null) return;

    setState(() => _isSpeaking = true);
    await _tts.speak(_details!.ttsAnnouncement);
  }

  Future<void> _downloadReceipt() async {
    if (_details == null || !_details!.canDownloadReceipt) return;

    setState(() => _isDownloadingReceipt = true);

    try {
      // TODO: Implement actual PDF download
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt downloaded successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download receipt.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingReceipt = false);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _details != null ? 'Transaction ${_details!.id.split('-').last}' : 'Details',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isSpeaking
                ? () {
                    _tts.stop();
                    setState(() => _isSpeaking = false);
                  }
                : _speakDetails,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            tooltip: _isSpeaking ? 'Stop reading' : 'Read aloud',
          ),
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _details == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error ?? 'Something went wrong'),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _loadDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary header
          _buildOrderHeader(colorScheme),

          const SizedBox(height: AppSpacing.lg),

          // Timeline (AC4)
          _buildTimeline(colorScheme),

          const SizedBox(height: AppSpacing.lg),

          // Payment breakdown (AC4)
          PaymentBreakdownCard(
            payment: _details!.payment,
            onVoiceRead: () async {
              await _tts.speak(_details!.payment.ttsAnnouncement);
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Receipt download (AC5)
          ReceiptDownloadButton(
            canDownload: _details!.canDownloadReceipt,
            isLoading: _isDownloadingReceipt,
            onPressed: _downloadReceipt,
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Crop icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _details!.cropEmoji,
                  style: const TextStyle(fontSize: 32),
                  semanticsLabel: _details!.cropType,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_details!.formattedQuantity} ${_details!.cropType}',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _details!.buyerDisplay,
                    style: AppTypography.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _details!.formattedDate,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _details!.payment.formattedNetAmount,
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Order Timeline',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Timeline events
            ...List.generate(_details!.timeline.length, (index) {
              final event = _details!.timeline[index];
              final isLast = index == _details!.timeline.length - 1;

              return _TimelineItem(
                event: event,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TransactionTimelineEvent event;
  final bool isLast;

  const _TimelineItem({
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: event.completed
                      ? AppColors.secondary
                      : (event.active
                          ? AppColors.primary
                          : colorScheme.surfaceContainerHighest),
                  shape: BoxShape.circle,
                  border: !event.completed && !event.active
                      ? Border.all(color: colorScheme.outlineVariant, width: 2)
                      : null,
                ),
                child: event.completed
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (event.active
                        ? const Icon(Icons.circle, size: 10, color: Colors.white)
                        : null),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: event.completed
                      ? AppColors.secondary
                      : colorScheme.outlineVariant,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: AppTypography.titleSmall.copyWith(
                    color: event.completed || event.active
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        event.active ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (event.formattedTimestamp != null)
                  Text(
                    event.formattedTimestamp!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
