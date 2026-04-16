import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';
import 'solution_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _load();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final h = await HistoryService.getHistory();
    if (mounted) {
      setState(() {
        _history = h;
        _isLoading = false;
      });
      _listCtrl.forward();
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1630),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History',
            style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.bold)),
        content: const Text('Remove all diagnosis history?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear',
                  style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.clearHistory();
      _listCtrl.reset();
      await _load();
    }
  }

  String _timeAgo(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Diagnosis History',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text,
                            letterSpacing: -0.3)),
                  ),
                  if (_history.isNotEmpty)
                    GestureDetector(
                      onTap: _clearAll,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        borderRadius: 10,
                        tintColor: AppTheme.error,
                        opacity: 0.1,
                        child: const Text('Clear',
                            style: TextStyle(
                                color: AppTheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary, strokeWidth: 2.5))
                  : _history.isEmpty
                      ? _EmptyState(
                          icon: Icons.history_rounded,
                          message: 'No history yet',
                          subtitle:
                              'Your diagnosed issues will\nappear here automatically.',
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _history.length,
                          itemBuilder: (context, i) {
                            final item = _history[i];
                            return _HistoryCard(
                              item: item,
                              index: i,
                              animation: _listCtrl,
                              timeAgo: _timeAgo(item['timestamp'] ?? ''),
                              onDelete: () async {
                                await HistoryService.removeEntry(
                                    item['brand'],
                                    item['appliance'],
                                    item['issue']);
                                _listCtrl.reset();
                                await _load();
                              },
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

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final AnimationController animation;
  final String timeAgo;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.item,
    required this.index,
    required this.animation,
    required this.timeAgo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.07).clamp(0.0, 0.6);
    final anim = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position:
              Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(anim),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Press3D(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => SolutionScreen(
                        brand: item['brand'],
                        appliance: item['appliance'],
                        issue: item['issue'],
                      ))),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGrad,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Icon(Icons.history_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['issue'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.text)),
                      const SizedBox(height: 3),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                              '${item['brand']} · ${item['appliance']}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryGlow,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 6),
                        Text(timeAgo,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.6))),
                      ]),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.message, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppTheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
