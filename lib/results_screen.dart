import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ==========================================
// SHARED DESIGN SYSTEM COLORS
// ==========================================
class ResultsColors {
  static const Color background = Color(0xFFF6F9F6);
  static const Color darkText = Color(0xFF003D33);
  static const Color tealText = Color(0xFF00695C);
  static const Color lightText = Color(0xFF757575);
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgTint = Color(0xFFF0F5F1);
  static const Color actionCardBg = Color(0xFF387155); // Matched slightly softer green from screenshot

  // Specific to Results Screen
  static const Color warningBrown = Color(0xFF8C5E4D);
  static const Color warningBgLight = Color(0xFFF7EBE6);
  static const Color dashedBorderBrown = Color(0xFFD7CCC8);
  static const Color optimalBadgeBg = Color(0xFFDCEADD);
  static const Color optimalBadgeText = Color(0xFF2E604A);
  static const Color detailedCardBg = Color(0xFFEAEFEB);
}

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResultsColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fake Top Bar (System header match)
            Container(
              color: const Color(0xFF1E2022),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.monitor, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Analysis Results', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Center align the top section
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 32),

                    // Alert Graphic Section
                    const AlertGraphic(),
                    const SizedBox(height: 20),

                    // Main Alert Text
                    const Text(
                      'Low Nitrogen Detected',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ResultsColors.darkText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Critical growth deficiency found in Zone A-12.\nImmediate intervention recommended.',
                        style: TextStyle(
                          fontSize: 12,
                          color: ResultsColors.lightText,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Data Cards
                    const NutrientStatusCard(),
                    const SizedBox(height: 16),
                    const SoilChemistryCard(),
                    const SizedBox(height: 16),
                    const DetailedFindingsCard(),
                    const SizedBox(height: 24),

                    // Action Card
                    const TreatmentActionCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8BAA0), // Darker peach color
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Digital Greenhouse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ResultsColors.darkText,
              ),
            ),
          ],
        ),
        const Icon(Icons.notifications, color: ResultsColors.actionCardBg, size: 22),
      ],
    );
  }
}

// ==========================================
// MODULAR WIDGETS FOR RESULTS SCREEN
// ==========================================

class AlertGraphic extends StatelessWidget {
  const AlertGraphic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: DashedCirclePainter(
          color: ResultsColors.dashedBorderBrown,
          strokeWidth: 2,
          dashWidth: 6,
          dashSpace: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: ResultsColors.warningBgLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.warning_rounded,
                color: ResultsColors.warningBrown,
                size: 44,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NutrientStatusCard extends StatelessWidget {
  const NutrientStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResultsColors.cardBgTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NUTRIENT STATUS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ResultsColors.lightText,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.water_drop, color: ResultsColors.warningBrown.withOpacity(0.8), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '32%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: ResultsColors.warningBrown,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nitrogen level',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ResultsColors.darkText),
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: 100, // Hardcoded approx 32%
                decoration: BoxDecoration(
                  color: ResultsColors.warningBrown,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SoilChemistryCard extends StatelessWidget {
  const SoilChemistryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResultsColors.cardBgTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SOIL CHEMISTRY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ResultsColors.lightText,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.science, color: ResultsColors.darkText.withOpacity(0.9), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '6.2',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ResultsColors.darkText,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ResultsColors.optimalBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OPTIMAL',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: ResultsColors.optimalBadgeText, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Soil pH level',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ResultsColors.darkText),
          ),
        ],
      ),
    );
  }
}

class DetailedFindingsCard extends StatelessWidget {
  const DetailedFindingsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResultsColors.detailedCardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: ResultsColors.actionCardBg, size: 20),
              SizedBox(width: 8),
              Text(
                'Detailed Findings',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ResultsColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // List Item 1: Temperature
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.thermostat, color: ResultsColors.warningBrown, size: 20),
                SizedBox(width: 12),
                Text('Temperature', style: TextStyle(fontSize: 13, color: ResultsColors.darkText)),
                Spacer(),
                Text('24°C', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ResultsColors.darkText)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // List Item 2: Humidity
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.water_drop_outlined, color: ResultsColors.actionCardBg, size: 20),
                SizedBox(width: 12),
                Text('Humidity', style: TextStyle(fontSize: 13, color: ResultsColors.darkText)),
                Spacer(),
                Text('68%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ResultsColors.darkText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TreatmentActionCard extends StatelessWidget {
  const TreatmentActionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ResultsColors.actionCardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to treat?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Our AI recommends a customized nitrogen boost for Zone A-12 to stabilize growth within 72 hours.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFC8E6D3), // Lighter green text
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Treatment/Advice details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ResultsColors.actionCardBg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text('View Advice', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// Configured Bottom Nav Bar specifically for Results screen


 
// Custom Painter to draw the dashed circular border seen in the design
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double length = math.min(dashWidth, pathMetric.length - distance);
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + length),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}