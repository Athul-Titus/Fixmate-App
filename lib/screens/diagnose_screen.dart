import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/picker_sheet.dart';
import 'solution_screen.dart';

class DiagnoseScreen extends StatefulWidget {
  const DiagnoseScreen({super.key});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  bool _isLoading = false;
  String _error = '';

  List<String> _brands = [];
  List<String> _appliances = [];
  List<String> _issues = [];

  String? _selectedBrand;
  String? _selectedAppliance;
  String? _selectedIssue;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      _brands = await ApiService.getBrands();
    } catch (e) {
      _error = 'Failed to load brands. Please try again.';
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadAppliances(String brand) async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      _appliances = await ApiService.getAppliances(brand);
    } catch (e) {
      _error = 'Failed to load appliances. Please try again.';
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadIssues(String brand, String appliance) async {
    setState(() { _isLoading = true; _error = ''; });
    try {
      _issues = await ApiService.getIssues(brand, appliance);
    } catch (e) {
      _error = 'Failed to load issues. Please try again.';
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _onBrandSelected(String brand) {
    setState(() {
      _selectedBrand = brand;
      _selectedAppliance = null;
      _selectedIssue = null;
      _appliances = [];
      _issues = [];
    });
    _loadAppliances(brand);
  }

  void _onApplianceSelected(String appliance) {
    setState(() {
      _selectedAppliance = appliance;
      _selectedIssue = null;
      _issues = [];
    });
    _loadIssues(_selectedBrand!, appliance);
  }

  void _onIssueSelected(String issue) {
    setState(() {
      _selectedIssue = issue;
    });
  }

  void _showPicker(String title, List<String> items, Function(String) onItemSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
             return SingleChildScrollView(
               controller: controller,
               child: PickerSheet(
                 title: title,
                 items: items,
                 onItemSelected: onItemSelected,
               ),
             );
          },
        );
      },
    );
  }

  void _reset() {
    setState(() {
      _selectedBrand = null;
      _selectedAppliance = null;
      _selectedIssue = null;
      _appliances = [];
      _issues = [];
      _error = '';
    });
  }

  void _findSolution() {
    if (_selectedBrand == null || _selectedAppliance == null || _selectedIssue == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolutionScreen(
          brand: _selectedBrand!,
          appliance: _selectedAppliance!,
          issue: _selectedIssue!,
        ),
      ),
    );
  }

  Widget _buildSelectorButton({
    required String title,
    required String? value,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? AppTheme.surface : AppTheme.surface.withValues(alpha: 0.5),
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'Select $title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
                    color: value != null ? AppTheme.text : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: enabled ? AppTheme.primary : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnose Issue'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'What needs fixing?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.text),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your device configuration to find a quick solution.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_error, style: const TextStyle(color: AppTheme.error)),
                  ),

                _buildSelectorButton(
                  title: 'Brand',
                  value: _selectedBrand,
                  enabled: _brands.isNotEmpty,
                  onTap: () => _showPicker('Select Brand', _brands, _onBrandSelected),
                ),
                const SizedBox(height: 16),
                
                _buildSelectorButton(
                  title: 'Appliance',
                  value: _selectedAppliance,
                  enabled: _selectedBrand != null && _appliances.isNotEmpty,
                  onTap: () => _showPicker('Select Appliance', _appliances, _onApplianceSelected),
                ),
                const SizedBox(height: 16),
                
                _buildSelectorButton(
                  title: 'Issue',
                  value: _selectedIssue,
                  enabled: _selectedAppliance != null && _issues.isNotEmpty,
                  onTap: () => _showPicker('Select Issue', _issues, _onIssueSelected),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Reset', style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _selectedIssue != null ? _findSolution : null,
                        child: const Text('Find Solution'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
