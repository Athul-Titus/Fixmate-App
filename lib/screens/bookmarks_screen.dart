import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';
import 'solution_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;
  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _load();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final b = await BookmarkService.getBookmarks();
    if (mounted) {
      setState(() {
        _bookmarks = b;
        _isLoading = false;
      });
      _listCtrl.forward();
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
                  const Text('Saved Solutions',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.text,
                          letterSpacing: -0.3)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary, strokeWidth: 2.5))
                  : _bookmarks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_border_rounded,
                                  size: 64,
                                  color: AppTheme.accentPink.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              const Text('No saved solutions',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.text)),
                              const SizedBox(height: 8),
                              const Text(
                                  'Tap the bookmark icon on any\nsolution to save it here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      height: 1.5)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _bookmarks.length,
                          itemBuilder: (context, i) {
                            final item = _bookmarks[i];
                            final delay = (i * 0.07).clamp(0.0, 0.6);
                            final anim = CurvedAnimation(
                              parent: _listCtrl,
                              curve: Interval(delay,
                                  (delay + 0.4).clamp(0.0, 1.0),
                                  curve: Curves.easeOut),
                            );
                            return AnimatedBuilder(
                              animation: anim,
                              builder: (_, child) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween(
                                          begin: const Offset(0, 0.15),
                                          end: Offset.zero)
                                      .animate(anim),
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
                                            gradient: AppTheme.accentGrad,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: AppTheme.accentPink
                                                      .withValues(alpha: 0.35),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3))
                                            ],
                                          ),
                                          child: const Icon(
                                              Icons.bookmark_rounded,
                                              color: Colors.white,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item['issue'] ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: AppTheme.text)),
                                              const SizedBox(height: 3),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentPink
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                    '${item['brand']} · ${item['appliance']}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: AppTheme.accentPink,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await BookmarkService.removeBookmark(
                                                item['brand'],
                                                item['appliance'],
                                                item['issue']);
                                            _listCtrl.reset();
                                            await _load();
                                          },
                                          child: Icon(Icons.close_rounded,
                                              color: AppTheme.textSecondary
                                                  .withValues(alpha: 0.5),
                                              size: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
