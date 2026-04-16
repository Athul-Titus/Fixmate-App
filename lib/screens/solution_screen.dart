import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SolutionScreen extends StatefulWidget {
  final String brand;
  final String appliance;
  final String issue;

  const SolutionScreen({
    super.key,
    required this.brand,
    required this.appliance,
    required this.issue,
  });

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String _error = '';
  String _solutionText = '';
  List<String> _quickTips = [];
  bool _isBookmarked = false;

  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fetchSolution();
    _checkBookmark();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBookmark() async {
    final v = await BookmarkService.isBookmarked(
        widget.brand, widget.appliance, widget.issue);
    if (mounted) setState(() => _isBookmarked = v);
  }

  Future<void> _fetchSolution() async {
    try {
      final r = await ApiService.getSolution(
          widget.brand, widget.appliance, widget.issue);
      setState(() {
        _solutionText = r['fix'] ?? r['solution'] ?? 'No solution found.';
        final tips = r['quickTips'];
        _quickTips = (tips is List)
            ? tips.cast<String>()
            : [
                'Try restarting the appliance first.',
                'Ensure power supply is stable.',
                'Keep the model/serial number ready when calling a technician.',
              ];
      });

      // Auto-save to history
      await HistoryService.addEntry(
        brand: widget.brand,
        appliance: widget.appliance,
        issue: widget.issue,
        solution: _solutionText,
      );
    } catch (_) {
      setState(() => _error = 'Failed to load solution. Please try again.');
    } finally {
      setState(() => _isLoading = false);
      _entryCtrl.forward();
    }
  }

  Future<void> _toggleBookmark() async {
    final added = await BookmarkService.toggleBookmark(
      brand: widget.brand,
      appliance: widget.appliance,
      issue: widget.issue,
      solution: _solutionText,
    );
    setState(() => _isBookmarked = added);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? '⭐ Saved to bookmarks' : 'Removed from bookmarks'),
          backgroundColor: const Color(0xFF1E1A35),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: GlassCard(
                              padding: const EdgeInsets.all(10),
                              borderRadius: 12,
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: AppTheme.text, size: 20),
                            ),
                          ),
                          const Spacer(),
                          // Bookmark button
                          GestureDetector(
                            onTap: _toggleBookmark,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: _isBookmarked
                                    ? AppTheme.accentGrad
                                    : null,
                                color: _isBookmarked
                                    ? null
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _isBookmarked
                                        ? Colors.transparent
                                        : Colors.white.withValues(alpha: 0.14)),
                                boxShadow: _isBookmarked
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.accentPink
                                              .withValues(alpha: 0.4),
                                          blurRadius: 12,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                _isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Text('${widget.brand} · ${widget.appliance}',
                            style: const TextStyle(
                                color: AppTheme.primaryGlow,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      Text(widget.issue,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.text,
                            height: 1.25,
                            letterSpacing: -0.3,
                          )),
                    ],
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (_isLoading) ...[
                      const SizedBox(height: 60),
                      const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary, strokeWidth: 2.5)),
                    ] else ...[
                      AnimatedBuilder(
                        animation: _entryCtrl,
                        builder: (_, child) => FadeTransition(
                          opacity: _entryCtrl,
                          child: SlideTransition(
                            position: Tween(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero)
                                .animate(CurvedAnimation(
                                    parent: _entryCtrl,
                                    curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Solution card
                            GlassCardShimmer(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGrad,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary
                                                .withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const Icon(
                                          Icons.handyman_rounded,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Recommended Solution',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppTheme.text)),
                                  ]),
                                  const SizedBox(height: 16),
                                  Divider(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      height: 1),
                                  const SizedBox(height: 16),
                                  if (_error.isNotEmpty)
                                    Text(_error,
                                        style: const TextStyle(
                                            color: AppTheme.error))
                                  else
                                    Text(_solutionText,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: AppTheme.text,
                                            height: 1.75)),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Quick tips
                            if (_quickTips.isNotEmpty)
                              GlassCardShimmer(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.accentGrad,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.accentPink
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: const Icon(
                                            Icons.tips_and_updates_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Quick Tips',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppTheme.text)),
                                    ]),
                                    const SizedBox(height: 16),
                                    ..._quickTips.map((tip) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.success
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  border: Border.all(
                                                      color: AppTheme.success
                                                          .withValues(
                                                              alpha: 0.4)),
                                                ),
                                                child: const Icon(
                                                    Icons.check_rounded,
                                                    color: AppTheme.success,
                                                    size: 14),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Text(tip,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: AppTheme
                                                              .textSecondary,
                                                          height: 1.5))),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 18),

                            // Auto-saved label
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_rounded,
                                    size: 13,
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.5)),
                                const SizedBox(width: 5),
                                Text('Saved to history',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary
                                            .withValues(alpha: 0.5))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
