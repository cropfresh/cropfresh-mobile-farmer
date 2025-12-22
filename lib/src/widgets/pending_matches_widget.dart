import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../models/match_models.dart';
import '../widgets/match_widgets.dart';

/// Pending Matches Widget - Story 3.5 (AC: 6)
/// 
/// Dashboard widget showing list of pending matches.
/// Sorted by expiry time with empty state handling.
class PendingMatchesWidget extends StatelessWidget {
  final List<Match> matches;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final void Function(Match match)? onMatchTap;

  const PendingMatchesWidget({
    super.key,
    required this.matches,
    this.isLoading = false,
    this.onRefresh,
    this.onMatchTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count badge
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Pending Matches',
                    style: AppTypography.titleLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (matches.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.sm),
                    MatchBadge(count: matches.length),
                  ],
                ],
              ),
              if (onRefresh != null)
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Content
        if (isLoading && matches.isEmpty)
          _buildLoadingState()
        else if (matches.isEmpty)
          EmptyMatchesState(onRefresh: onRefresh)
        else
          _buildMatchesList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMatchesList() {
    // Sort by expiry time (soonest first)
    final sortedMatches = List<Match>.from(matches)
      ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
      ),
      itemCount: sortedMatches.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final match = sortedMatches[index];
        return MatchCard(
          match: match,
          onTap: onMatchTap != null ? () => onMatchTap!(match) : null,
        );
      },
    );
  }
}

/// Matches Screen - Full screen view of all matches (AC: 6)
class MatchesScreen extends StatefulWidget {
  final List<Match> matches;
  final Future<List<Match>> Function()? onRefresh;
  final void Function(Match match)? onMatchTap;

  const MatchesScreen({
    super.key,
    required this.matches,
    this.onRefresh,
    this.onMatchTap,
  });

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  late List<Match> _matches;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _matches = widget.matches;
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh == null) return;

    setState(() => _isRefreshing = true);
    try {
      final updatedMatches = await widget.onRefresh!();
      if (mounted) {
        setState(() => _matches = updatedMatches);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort by expiry time (soonest first)
    final sortedMatches = List<Match>.from(_matches)
      ..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Matches'),
            if (_matches.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              MatchBadge(count: _matches.length),
            ],
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _matches.isEmpty && !_isRefreshing
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: EmptyMatchesState(onRefresh: _handleRefresh),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                itemCount: sortedMatches.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final match = sortedMatches[index];
                  return MatchCard(
                    match: match,
                    onTap: widget.onMatchTap != null 
                        ? () => widget.onMatchTap!(match) 
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
