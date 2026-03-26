import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/service_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Services'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Professional help at your doorstep',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ServiceCard(
            title: 'Plumbing',
            description: 'Fast, local plumbers available for repairs and installations.',
            icon: Icons.plumbing,
          ),
          ServiceCard(
            title: 'Electrical',
            description: 'Certified electricians for wiring, switches, and more.',
            icon: Icons.electrical_services,
          ),
          ServiceCard(
            title: 'AC Service',
            description: 'Maintenance, gas top-up and full repairs.',
            icon: Icons.ac_unit,
          ),
        ],
      ),
    );
  }
}
