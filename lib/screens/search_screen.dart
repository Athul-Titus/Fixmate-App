import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _error = '';

  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() { _listCtrl.dispose(); _ctrl.dispose(); super.dispose(); }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _error = ''; _hasSearched = true; });
    try {
      final r = await ApiService.search(q);
      setState(() {
        _results = r['results'] ?? [];
        if (_results.isEmpty) _error = 'No results found for "$q"';
      });
      _listCtrl.forward(from: 0);
    } catch (_) {
      setState(() => _error = 'Search failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search', style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900,
                    color: AppTheme.text, letterSpacing: -0.5,
                  )),
                  const SizedBox(height: 4),
                  const Text('Find fixes for any issue', style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 16,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search_rounded, color: AppTheme.primaryGlow),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            style: const TextStyle(color: AppTheme.text, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'e.g. AC not cooling, fridge noise...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        Press3D(
                          onTap: _search,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGrad,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 10, offset: const Offset(0, 3),
                              )],
                            ),
                            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Results ───────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5))
                  : _error.isNotEmpty
                      ? Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 60, color: AppTheme.textSecondary),
                            const SizedBox(height: 12),
                            Text(_error, style: const TextStyle(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center),
                          ],
                        ))
                      : !_hasSearched
                          ? Center(child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.travel_explore_rounded, size: 64,
                                  color: AppTheme.primary.withValues(alpha: 0.35)),
                                const SizedBox(height: 12),
                                const Text('Search for appliance issues',
                                  style: TextStyle(color: AppTheme.textSecondary)),
                              ],
                            ))
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _results.length,
                              itemBuilder: (context, i) {
                                final item = _results[i];
                                return _SearchResultCard(
                                  item: item,
                                  index: i,
                                  animation: _listCtrl,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Map<dynamic, dynamic> item;
  final int index;
  final AnimationController animation;
  const _SearchResultCard({required this.item, required this.index, required this.animation});

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.08).clamp(0.0, 0.6);
    final anim = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Press3D(
          onTap: () => _showDetail(context),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGrad,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 10, offset: const Offset(0, 3),
                    )],
                  ),
                  child: const Icon(Icons.build_circle_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'] ?? 'Unknown Issue',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.text),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${item['brand']} · ${item['appliance']}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryGlow, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 4),
                    Text(item['snippet'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                  ],
                )),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        builder: (_, ctrl) => GlassCardShimmer(
          borderRadius: 28,
          child: SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${item['brand']} · ${item['appliance']}',
                    style: const TextStyle(color: AppTheme.primaryGlow, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(height: 12),
                Text(item['title'] ?? '', style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.text)),
                Divider(height: 28, color: Colors.white.withValues(alpha: 0.1)),
                Text(item['snippet'] ?? '', style: const TextStyle(
                  fontSize: 15, color: AppTheme.text, height: 1.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
