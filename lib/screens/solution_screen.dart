import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_overlay.dart';

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

class _SolutionScreenState extends State<SolutionScreen> {
  bool _isLoading = true;
  String _error = '';
  String _solutionText = '';
  String? _brandPageUrl;

  @override
  void initState() {
    super.initState();
    _fetchSolution();
  }

  Future<void> _fetchSolution() async {
    try {
      final response = await ApiService.getSolution(
        widget.brand,
        widget.appliance,
        widget.issue,
      );
      setState(() {
        _solutionText = response['solution'] ?? 'No solution found for this issue.';
        _brandPageUrl = response['brand_page'];
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load solution. Please check your connection and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildQuickTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (!_isLoading)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.brand} ${widget.appliance}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.issue,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(color: AppTheme.border),
                        ),
                        if (_error.isNotEmpty)
                          Text(_error, style: const TextStyle(color: AppTheme.error))
                        else
                          Text(
                            _solutionText,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.text,
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Tips',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildQuickTip('Try restarting the appliance before booking a visit.'),
                        _buildQuickTip('Keep a photo of the model/label when scheduling a technician.'),
                        _buildQuickTip('Use the Reset button to start over if the solution works.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_brandPageUrl != null && _brandPageUrl!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Visit Brand Support Page'),
                        onPressed: () {
                          // TODO: Launch URL using url_launcher
                        },
                      ),
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
