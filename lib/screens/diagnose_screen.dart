import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';
import '../widgets/picker_sheet.dart';
import 'solution_screen.dart';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  String _error = '';

  List<String> _brands = [];
  List<String> _appliances = [];
  List<String> _issues = [];

  String? _selectedBrand;
  String? _selectedAppliance;
  String? _selectedIssue;

  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _loadBrands();
  }

  @override
  void dispose() { _entryCtrl.dispose(); super.dispose(); }

  Future<void> _loadBrands() async {
    setState(() { _isLoading = true; _error = ''; });
    try { _brands = await ApiService.getBrands(); }
    catch (_) { _error = 'Failed to load brands.'; }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _loadAppliances(String brand) async {
    setState(() { _isLoading = true; _error = ''; });
    try { _appliances = await ApiService.getAppliances(brand); }
    catch (_) { _error = 'Failed to load appliances.'; }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _loadIssues(String brand, String appliance) async {
    setState(() { _isLoading = true; _error = ''; });
    try { _issues = await ApiService.getIssues(brand, appliance); }
    catch (_) { _error = 'Failed to load issues.'; }
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  void _onBrandSelected(String b) {
    setState(() { _selectedBrand = b; _selectedAppliance = null; _selectedIssue = null; _appliances = []; _issues = []; });
    _loadAppliances(b);
  }

  void _onApplianceSelected(String a) {
    setState(() { _selectedAppliance = a; _selectedIssue = null; _issues = []; });
    _loadIssues(_selectedBrand!, a);
  }

  void _onIssueSelected(String issue) => setState(() => _selectedIssue = issue);

  void _showPicker(String title, List<String> items, void Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          child: PickerSheet(title: title, items: items, onItemSelected: onSelected),
        ),
      ),
    );
  }

  void _reset() => setState(() {
    _selectedBrand = null; _selectedAppliance = null; _selectedIssue = null;
    _appliances = []; _issues = []; _error = '';
  });

  @override
  Widget build(BuildContext context) {
    final canFindSolution = _selectedIssue != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: AnimatedBuilder(
                      animation: _entryCtrl,
                      builder: (_, child) => FadeTransition(
                        opacity: _entryCtrl,
                        child: SlideTransition(
                          position: Tween(begin: const Offset(0, 0.12), end: Offset.zero)
                              .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Diagnose', style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.w900,
                            color: AppTheme.text, letterSpacing: -0.5,
                          )),
                          const SizedBox(height: 4),
                          const Text('Select brand → appliance → issue', style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // Step selectors
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_error.isNotEmpty) ...[
                        GlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 14,
                          tintColor: AppTheme.error,
                          opacity: 0.1,
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                            const SizedBox(width: 8),
                            Text(_error, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                          ]),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _StepSelector(
                        step: 1,
                        label: 'Brand',
                        value: _selectedBrand,
                        enabled: _brands.isNotEmpty && !_isLoading,
                        onTap: () => _showPicker('Select Brand', _brands, _onBrandSelected),
                      ),
                      const SizedBox(height: 12),
                      _StepSelector(
                        step: 2,
                        label: 'Appliance',
                        value: _selectedAppliance,
                        enabled: _selectedBrand != null && _appliances.isNotEmpty && !_isLoading,
                        onTap: () => _showPicker('Select Appliance', _appliances, _onApplianceSelected),
                      ),
                      const SizedBox(height: 12),
                      _StepSelector(
                        step: 3,
                        label: 'Issue',
                        value: _selectedIssue,
                        enabled: _selectedAppliance != null && _issues.isNotEmpty && !_isLoading,
                        onTap: () => _showPicker('Select Issue', _issues, _onIssueSelected),
                      ),

                      const SizedBox(height: 28),

                      // Action row
                      Row(
                        children: [
                          Press3D(
                            onTap: _reset,
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              borderRadius: 16,
                              child: Row(
                                children: [
                                  const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary, size: 18),
                                  const SizedBox(width: 6),
                                  const Text('Reset', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlowButton(
                              label: 'Find Solution',
                              icon: Icons.search_rounded,
                              onPressed: canFindSolution
                                  ? () => Navigator.of(context).push(
                                      _slideUpRoute(SolutionScreen(
                                        brand: _selectedBrand!,
                                        appliance: _selectedAppliance!,
                                        issue: _selectedIssue!,
                                      )))
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ]),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Positioned.fill(
                child: Center(child: _GlassLoader()),
              ),
          ],
        ),
      ),
    );
  }
}

Route<T> _slideUpRoute<T>(Widget page) => PageRouteBuilder(
  pageBuilder: (_, a, __) => page,
  transitionDuration: const Duration(milliseconds: 400),
  reverseTransitionDuration: const Duration(milliseconds: 300),
  transitionsBuilder: (_, a, __, child) => FadeTransition(
    opacity: a,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

class _StepSelector extends StatelessWidget {
  final int step;
  final String label;
  final String? value;
  final bool enabled;
  final VoidCallback onTap;
  const _StepSelector({required this.step, required this.label, required this.value,
    required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selected = value != null;
    return Press3D(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 18,
          opacity: enabled ? 0.12 : 0.05,
          tintColor: selected ? AppTheme.primary : Colors.white,
          showBorder: true,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.primaryGrad : null,
                  color: selected ? null : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected ? [BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    blurRadius: 10, offset: const Offset(0, 4),
                  )] : null,
                ),
                child: Center(
                  child: selected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : Text('$step', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,
                          color: enabled ? AppTheme.primary : AppTheme.textSecondary)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: selected ? AppTheme.primaryGlow : AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 3),
                  Text(value ?? 'Tap to select $label',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? AppTheme.text : AppTheme.textSecondary,
                    )),
                ],
              )),
              Icon(Icons.arrow_forward_ios_rounded, size: 13,
                color: enabled ? AppTheme.textSecondary : Colors.white.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassLoader extends StatelessWidget {
  const _GlassLoader();
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(24),
    borderRadius: 20,
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
        SizedBox(height: 14),
        Text('Loading...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      ],
    ),
  );
}
