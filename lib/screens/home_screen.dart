import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/service_card.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const HomeScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.build_circle, size: 80, color: AppTheme.surface),
                    const SizedBox(height: 16),
                    const Text(
                      'FixMate',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.surface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Book Skilled Help Fast',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.surface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Find technicians, schedule visits, and get step-by-step fixes for common issues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.surface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.surface,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await ApiService.seedDatabase();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Firebase Database Seeded Automatically!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.cloud_upload, color: AppTheme.surface),
                      label: const Text('Seed Test Data to Firebase', style: TextStyle(color: AppTheme.surface)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Services Preview Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ServiceCard(
                title: 'Plumbing',
                description: 'Fast, local plumbers available for repairs and installations.',
                icon: Icons.plumbing,
              ),
              const ServiceCard(
                title: 'Electrical',
                description: 'Certified electricians for wiring, switches, and more.',
                icon: Icons.electrical_services,
              ),
              const ServiceCard(
                title: 'AC Service',
                description: 'Maintenance, gas top-up and full repairs.',
                icon: Icons.ac_unit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
