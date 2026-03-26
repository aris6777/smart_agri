import 'package:flutter/material.dart';

// ==========================================
// SHARED DESIGN SYSTEM COLORS
// Reuse these or move to a core theme file
// ==========================================
class ScanColors {
  static const Color background = Color(0xFFF6F9F6);
  static const Color darkText = Color(0xFF003D33);
  static const Color tealText = Color(0xFF00695C);
  static const Color lightText = Color(0xFF757575);
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgTint = Color(0xFFF0F5F1);
  static const Color actionCardBg = Color(0xFF135A3B);
  
  // Specific to Plant Scan Screen
  static const Color cameraBgBeige = Color(0xFFFAF0E6);
  static const Color warningText = Color(0xFF8C5C4D); // Warm brown/red
  static const Color warningBadgeBg = Color(0xFFFFCCBC);
  static const Color diseaseCardBg = Color(0xFFE4E9E5);
}

class PlantScanScreen extends StatefulWidget {
  const PlantScanScreen({Key? key}) : super(key: key);

  @override
  State<PlantScanScreen> createState() => _PlantScanScreenState();
}

class _PlantScanScreenState extends State<PlantScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScanColors.background,
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
                  Text('Plant Scan', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                    const SizedBox(height: 24),
                    
                    // Live Camera Area (Placeholder as requested)
                    const CameraPlaceholderCard(),
                    const SizedBox(height: 28),
                    
                    // Diagnosis Results Section
                    _buildDiagnosisHeader(),
                    const SizedBox(height: 16),
                    
                    const HealthConditionCard(),
                    const SizedBox(height: 12),
                    
                    const DiseaseCard(),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    const ScanActionButtons(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation (Scan tab active)
            const CustomBottomNavBarScanMode(),
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
                color: ScanColors.darkText,
              ),
            ),
          ],
        ),
        const Icon(Icons.notifications_active, color: ScanColors.actionCardBg, size: 22),
      ],
    );
  }

  Widget _buildDiagnosisHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DIAGNOSIS RESULT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: ScanColors.lightText,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'AI Analysis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ScanColors.darkText,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE1E6D8), // Light olive green tint
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.psychology, color: ScanColors.actionCardBg, size: 20),
        ),
      ],
    );
  }
}

// ==========================================
// MODULAR WIDGETS FOR PLANT SCAN SCREEN
// ==========================================

class CameraPlaceholderCard extends StatelessWidget {
  const CameraPlaceholderCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 340, // Fixed height to match layout proportion
      decoration: BoxDecoration(
        color: ScanColors.cameraBgBeige,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          // Dark Grey Placeholder requested in prompt
          Center(
            child: Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                // Emulating the green bounding box around the device
                border: Border.all(color: ScanColors.actionCardBg, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.camera_alt, color: Colors.white, size: 48),
              ),
            ),
          ),
          
          // "LIVE ANALYSIS" Badge
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'LIVE ANALYSIS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ScanColors.darkText, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
          
          // Flash Button
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on, color: ScanColors.darkText, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class HealthConditionCard extends StatelessWidget {
  const HealthConditionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ScanColors.cardBgTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Health condition',
                style: TextStyle(fontSize: 12, color: ScanColors.lightText, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ScanColors.warningBadgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Warning',
                  style: TextStyle(fontSize: 10, color: Color(0xFFBF360C), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Attention Required',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ScanColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}

class DiseaseCard extends StatelessWidget {
  const DiseaseCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ScanColors.diseaseCardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Possible disease',
            style: TextStyle(fontSize: 12, color: ScanColors.lightText, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          Text(
            'Leaf Spot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ScanColors.actionCardBg, // Dark green
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Fungal infection suspected',
            style: TextStyle(fontSize: 12, color: ScanColors.lightText),
          ),
        ],
      ),
    );
  }
}

class ScanActionButtons extends StatelessWidget {
  const ScanActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Trigger camera re-scan
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ScanColors.actionCardBg,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                Text('Re-scan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // TODO: Navigate to details screen
          },
          style: TextButton.styleFrom(
            foregroundColor: ScanColors.actionCardBg,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// Configured Bottom Nav Bar specifically for the Scan screen (Scan icon is active)
class CustomBottomNavBarScanMode extends StatelessWidget {
  const CustomBottomNavBarScanMode({Key? key}) : super(key: key);

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
          // --- CLICKABLE DASHBOARD BUTTON (GO BACK) ---
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // This removes the scan screen and reveals the dashboard!
            },
            child: _buildNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          ),
          // --------------------------------------------
          _buildNavItem(icon: Icons.document_scanner, label: 'Scan', isActive: true),
          _buildNavItem(icon: Icons.analytics_outlined, label: 'Results'),
          _buildNavItem(icon: Icons.lightbulb_outline, label: 'Advice'),
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
              ? BoxDecoration(color: ScanColors.cardBgTint, borderRadius: BorderRadius.circular(12))
              : null,
          child: Icon(
            icon,
            color: isActive ? ScanColors.actionCardBg : Colors.grey.shade500,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? ScanColors.actionCardBg : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }
}