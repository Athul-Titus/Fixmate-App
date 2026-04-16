import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/press_3d_button.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Services',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.text,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    const Text('Book professional repair services',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 24),

                    // Featured banner
                    Tilt3DCard(
                      child: GlassCardShimmer(
                        padding: const EdgeInsets.all(22),
                        borderRadius: 24,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppTheme.success
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: const Text('FREE First Inspection',
                                        style: TextStyle(
                                            color: AppTheme.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Professional\nRepair at Home',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1.2)),
                                  const SizedBox(height: 10),
                                  GlowButton(
                                    label: 'Book Now',
                                    icon: Icons.calendar_today_rounded,
                                    onPressed: () =>
                                        _showBookingForm(context, 'General Service'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGrad,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6))
                                ],
                              ),
                              child: const Icon(Icons.home_repair_service_rounded,
                                  size: 42, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Our Services',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text)),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // Service cards grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildListDelegate(_serviceCards(context)),
              ),
            ),

            // How it works
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How It Works',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text)),
                    const SizedBox(height: 16),
                    _StepRow(
                        step: '1',
                        title: 'Choose a Service',
                        subtitle: 'Select the appliance category',
                        gradient: AppTheme.primaryGrad),
                    _StepRow(
                        step: '2',
                        title: 'Pick a Time Slot',
                        subtitle: 'Choose date and arrival time',
                        gradient: AppTheme.accentGrad),
                    _StepRow(
                        step: '3',
                        title: 'Technician Arrives',
                        subtitle: 'Certified expert at your doorstep',
                        gradient: AppTheme.cyanGrad),
                    _StepRow(
                        step: '4',
                        title: 'Pay & Rate',
                        subtitle: 'Secure payment, rate the service',
                        gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)])),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _serviceCards(BuildContext context) {
    final services = [
      _ServiceData('AC Service', Icons.ac_unit_rounded, AppTheme.cyanGrad,
          '₹499 onwards', 'Cleaning, gas refill, repair'),
      _ServiceData('Washing Machine', Icons.local_laundry_service_rounded,
          AppTheme.primaryGrad, '₹399 onwards', 'All brands, all issues'),
      _ServiceData('Refrigerator', Icons.kitchen_rounded, AppTheme.accentGrad,
          '₹349 onwards', 'Cooling issues, noise fix'),
      _ServiceData('Microwave', Icons.microwave_rounded,
          const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
          '₹299 onwards', 'All models serviced'),
      _ServiceData(
          'TV & Electronics',
          Icons.tv_rounded,
          const LinearGradient(
              colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)]),
          '₹449 onwards',
          'Smart TV, LED, OLED'),
      _ServiceData(
          'Water Purifier',
          Icons.water_rounded,
          const LinearGradient(
              colors: [Color(0xFF5B8AF0), Color(0xFF7C6FF7)]),
          '₹249 onwards',
          'Filter change, repair'),
    ];

    return services.map((s) {
      return Press3D(
        onTap: () => _showBookingForm(context, s.title),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: s.gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: s.gradient.colors.first.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(s.icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(s.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.text)),
              const SizedBox(height: 3),
              Text(s.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: s.gradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s.price,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showBookingForm(BuildContext context, String service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(service: service),
    );
  }
}

class _ServiceData {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final String price;
  final String subtitle;
  const _ServiceData(
      this.title, this.icon, this.gradient, this.price, this.subtitle);
}

class _StepRow extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  const _StepRow(
      {required this.step,
      required this.title,
      required this.subtitle,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]),
            child: Center(
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15))),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.text)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ],
      ),
    );
  }
}

class _BookingSheet extends StatefulWidget {
  final String service;
  const _BookingSheet({required this.service});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedSlot;
  bool _submitted = false;

  final _slots = ['9AM–11AM', '11AM–1PM', '2PM–4PM', '4PM–6PM', '6PM–8PM'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      builder: (_, ctrl) => GlassCardShimmer(
        borderRadius: 28,
        child: SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: _submitted ? _SuccessView() : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Book ${widget.service}',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.text)),
              const SizedBox(height: 4),
              const Text('A certified technician will visit your home',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.text),
                decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppTheme.text),
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 20),
              const Text('Preferred Time Slot',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.text)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _slots.map((slot) {
                  final selected = _selectedSlot == slot;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient:
                            selected ? AppTheme.primaryGrad : null,
                        color: selected ? null : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : Colors.white.withValues(alpha: 0.14)),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.4),
                                    blurRadius: 10)
                              ]
                            : null,
                      ),
                      child: Text(slot,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              GlowButton(
                label: 'Confirm Booking',
                icon: Icons.check_circle_rounded,
                onPressed: () {
                  if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _selectedSlot == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please fill all fields and select a slot'),
                      backgroundColor: Color(0xFF1E1A35),
                    ));
                    return;
                  }
                  setState(() => _submitted = true);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: const Icon(Icons.check_rounded, size: 44, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text('Booking Confirmed!',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.text)),
        const SizedBox(height: 8),
        const Text('A technician will contact you\nwithin 30 minutes to confirm.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 14, height: 1.5)),
        const SizedBox(height: 28),
        GlowButton(
          label: 'Done',
          colors: [const Color(0xFF10B981), const Color(0xFF34D399)],
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
