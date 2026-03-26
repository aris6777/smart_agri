import 'package:flutter/material.dart';

// ==========================================
// SHARED DESIGN SYSTEM COLORS
// ==========================================
class AdviceColors {
  static const Color background = Color(0xFFF6F9F6);
  static const Color darkText = Color(0xFF003D33);
  static const Color tealText = Color(0xFF00695C);
  static const Color lightText = Color(0xFF757575);
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgTint = Color(0xFFF0F5F1);
  static const Color actionCardBg = Color(0xFF135A3B); // Dark green

  // Specific to Advice Screen
  static const Color waterCardBg = Color(0xFFE2EFE7);
  static const Color waterIconBg = Color(0xFFBBE0CA);
  static const Color limeIconBg = Color(0xFFCEEA75);
  static const Color textBrown = Color(0xFF6D5642);
  static const Color textOlive = Color(0xFF556037);
  static const Color peachIconBg = Color(0xFFFFDBCF);
  static const Color peachButtonBg = Color(0xFFEABEA8);
  static const Color proTipBg = Color(0xFFEBEFEB);
}

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({Key? key}) : super(key: key);

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdviceColors.background,
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
                  Text('Recommendations', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 28),
                    
                    // Title Section
                    const Text(
                      'Daily Care',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AdviceColors.actionCardBg, // Match the dark green heading
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Personalized recommendations based on\nyour soil and plant health analysis.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AdviceColors.lightText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recommendation Cards
                    const WateringAdviceCard(),
                    const SizedBox(height: 16),
                    const FertilizerAdviceCard(),
                    const SizedBox(height: 16),
                    const TreatmentAdviceCard(),
                    const SizedBox(height: 16),
                    const ProTipCard(),
                    const SizedBox(height: 28),

                    // History Link
                    Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history, color: AdviceColors.actionCardBg, size: 16),
                        label: const Text(
                          'View past analysis results',
                          style: TextStyle(
                            color: AdviceColors.actionCardBg,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation (Advice tab active)
            const CustomBottomNavBarAdviceMode(),
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
                color: const Color(0xFFF4CFC3), // Light peach color
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smartphone, color: Colors.white, size: 20), // Placeholder icon
            ),
            const SizedBox(width: 12),
            const Text(
              'Digital Greenhouse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AdviceColors.darkText,
              ),
            ),
          ],
        ),
        const Icon(Icons.notifications, color: AdviceColors.actionCardBg, size: 22),
      ],
    );
  }
}

// ==========================================
// MODULAR WIDGETS FOR ADVICE SCREEN
// ==========================================

class WateringAdviceCard extends StatelessWidget {
  const WateringAdviceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdviceColors.waterCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WATERING ADVICE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AdviceColors.darkText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add 500ml of water\ntoday',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AdviceColors.darkText,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AdviceColors.waterIconBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop, color: AdviceColors.darkText, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.crop_square, color: Colors.grey.shade400, size: 20), // Unchecked box
                const SizedBox(width: 12),
                const Text(
                  'Target moisture level: 65%',
                  style: TextStyle(fontSize: 12, color: AdviceColors.darkText, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FertilizerAdviceCard extends StatelessWidget {
  const FertilizerAdviceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdviceColors.cardBgTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdviceColors.limeIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: AdviceColors.darkText, size: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'FERTILIZER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AdviceColors.textOlive,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Apply high-nitrogen organic\nfertilizer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdviceColors.darkText,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildBulletPoint('Best applied before sunset'),
          const SizedBox(height: 6),
          _buildBulletPoint('Dilute 1:10 with water'),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 8),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AdviceColors.actionCardBg,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: AdviceColors.darkText, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class TreatmentAdviceCard extends StatelessWidget {
  const TreatmentAdviceCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdviceColors.cardBgTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdviceColors.peachIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.content_cut, color: AdviceColors.textBrown, size: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'TREATMENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AdviceColors.textBrown,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Prune infected leaves',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdviceColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AdviceColors.peachButtonBg,
                foregroundColor: AdviceColors.darkText,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('View guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class ProTipCard extends StatelessWidget {
  const ProTipCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdviceColors.proTipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated image circle 
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.grass, color: Colors.white54, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip: Lighting',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdviceColors.darkText),
                ),
                SizedBox(height: 6),
                Text(
                  '"The morning sun provides the most efficient photosynthesis for your current growth stage."',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AdviceColors.lightText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Configured Bottom Nav Bar specifically for Advice screen
class CustomBottomNavBarAdviceMode extends StatelessWidget {
  const CustomBottomNavBarAdviceMode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // --- GO BACK HOME BUTTON ---
          GestureDetector(
            onTap: () {
              Navigator.pop(context); 
            },
            child: _buildNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          ),
          // ---------------------------
          _buildNavItem(icon: Icons.document_scanner_outlined, label: 'Scan'),
          _buildNavItem(icon: Icons.analytics_outlined, label: 'Results'),
          _buildNavItem(icon: Icons.psychology, label: 'Advice', isActive: true), // Changed icon to match UI
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isActive ? 8.0 : 0.0),
          decoration: isActive 
              ? BoxDecoration(color: AdviceColors.proTipBg, borderRadius: BorderRadius.circular(12))
              : null,
          child: Icon(
            icon,
            color: isActive ? AdviceColors.actionCardBg : Colors.grey.shade500,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AdviceColors.actionCardBg : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }
}