import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'results_screen.dart';
import 'advice_screen.dart';

void main() {
  runApp(const SmartAgriApp());
}

class SmartAgriApp extends StatelessWidget {
  const SmartAgriApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Greenhouse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Using standard font, adjust if you have a specific custom font
        scaffoldBackgroundColor: const Color(0xFFF6F9F6), // Off-white/light sage background
        primaryColor: const Color(0xFF135A3B),
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- App Colors ---
class AppColors {
  static const Color background = Color(0xFFF6F9F6);
  static const Color darkText = Color(0xFF003D33);
  static const Color tealText = Color(0xFF00695C);
  static const Color lightText = Color(0xFF757575);
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgTint = Color(0xFFF0F5F1);
  static const Color actionCardBg = Color(0xFF135A3B);
  static const Color accentGreen = Color(0xFFA5D6A7);
  static const Color alertRedBg = Color(0xFFFFE0B2); // Light orange/red tint
  static const Color iconBgGreen = Color(0xFFC8E6C9);
  static const Color iconBgYellow = Color(0xFFE6EE9C);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ==========================================
  // HARDWARE INTEGRATION STATE VARIABLES
  // Bind your Arduino/Sensor API data here
  // ==========================================
  double currentSoilMoisture = 68.0;
  double currentTemperature = 24.0;
  double currentPhLevel = 6.5;
  String nutrientStatus = "Moderate";
  String lastSyncTime = "2 mins ago";
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fake Top Bar to match the dark aesthetic in screenshot header
            Container(
              color: const Color(0xFF1E2022),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(
                children: [
                  Icon(Icons.monitor, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Dashboard', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            
            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 24),
                    _buildLiveStatus(),
                    const SizedBox(height: 24),
                    
                    // Sensor Data Cards
                    SoilMoistureCard(moistureLevel: currentSoilMoisture),
                    const SizedBox(height: 16),
                    TemperatureCard(temperature: currentTemperature),
                    const SizedBox(height: 16),
                    PhLevelCard(phLevel: currentPhLevel),
                    const SizedBox(height: 16),
                    NutrientsCard(status: nutrientStatus),
                    const SizedBox(height: 24),
                    
                    // Action & Alerts Sections
                    const OptimizationActionCard(),
                    const SizedBox(height: 24),
                    const RecentAlertsSection(),
                    const SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation Area
            const CustomBottomNavBar(),
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
                color: const Color(0xFFFFCCBC), // Light peach color
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.device_thermostat, color: Colors.brown, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Digital Greenhouse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
        const Icon(Icons.notifications_none, color: AppColors.darkText),
      ],
    );
  }

  Widget _buildLiveStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LIVE STATUS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vibrant Growth',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.tealText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cardBgTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync, size: 14, color: AppColors.tealText),
              const SizedBox(width: 6),
              Text(
                'Last sync: $lastSyncTime',
                style: const TextStyle(fontSize: 12, color: AppColors.tealText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// REUSABLE MODULAR WIDGETS
// ==========================================

class SoilMoistureCard extends StatelessWidget {
  final double moistureLevel;

  const SoilMoistureCard({Key? key, required this.moistureLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBgLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.iconBgGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.water_drop_outlined, color: AppColors.darkText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Good',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Soil Moisture', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w500)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                moistureLevel.toInt().toString(),
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
              const Text(
                ' %',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TemperatureCard extends StatelessWidget {
  final double temperature;

  const TemperatureCard({Key? key, required this.temperature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBgTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TEMPERATURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightText, letterSpacing: 1.0)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(temperature.toInt().toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                  const Text(' °C', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkText)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Optimal Range', style: TextStyle(fontSize: 12, color: AppColors.tealText)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iconBgYellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.thermostat, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }
}

class PhLevelCard extends StatelessWidget {
  final double phLevel;

  const PhLevelCard({Key? key, required this.phLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBgTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBE6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.science_outlined, color: Colors.brown, size: 20),
          ),
          const SizedBox(height: 12),
          const Text('pH Level', style: TextStyle(fontSize: 12, color: AppColors.lightText, fontWeight: FontWeight.w500)),
          Text(phLevel.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const Text('Neutral', style: TextStyle(fontSize: 12, color: AppColors.lightText)),
        ],
      ),
    );
  }
}

class NutrientsCard extends StatelessWidget {
  final String status;

  const NutrientsCard({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBgTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF689F38), // Darker green icon bg
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          const Text('Nutrients', style: TextStyle(fontSize: 12, color: AppColors.lightText, fontWeight: FontWeight.w500)),
          Text(status, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 8),
          // Custom Progress Bar
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                height: 4,
                width: 150, // Static width for demonstration, adjust dynamically based on logic later
                decoration: BoxDecoration(
                  color: const Color(0xFF558B2F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OptimizationActionCard extends StatelessWidget {
  const OptimizationActionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.actionCardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Optimization\nReady',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your current soil conditions are 92% aligned with the target profile for Romaine Lettuce. Start automated irrigation?',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.accentGreen,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, // Expand button to fit card style
            child: ElevatedButton(
              onPressed: () {
                // TODO: Trigger hardware irrigation API
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: AppColors.darkText,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text('Begin Irrigation cycle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentAlertsSection extends StatelessWidget {
  const RecentAlertsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Alerts',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
        ),
        const SizedBox(height: 16),
        
        // Alert Item 1
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBgTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.alertRedBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_outlined, color: Colors.brown, size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Light rain forecast', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText)),
                    Text('Expected at 4:00 PM today', style: TextStyle(fontSize: 12, color: AppColors.lightText)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Alert Item 2
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBgTint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.iconBgYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: AppColors.darkText, size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pump Efficiency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkText)),
                    Text('Energy usage optimized by 12%', style: TextStyle(fontSize: 12, color: AppColors.lightText)),
                  ],
                ),
              ),
              // Floating Action Button style inside row
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.actionCardBg,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: () {},
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Bottom Navigation Bar to match specific style
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

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
          _buildNavItem(icon: Icons.dashboard, label: 'Dashboard', isActive: true),
          // --- NEW CLICKABLE SCAN BUTTON ---
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlantScanScreen()),
              );
            },
            child: _buildNavItem(icon: Icons.document_scanner_outlined, label: 'Scan'),
          ),
          // ---------------------------------
          // --- NEW CLICKABLE RESULTS BUTTON ---
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResultsScreen()), 
              );
            },
            child: _buildNavItem(icon: Icons.analytics_outlined, label: 'Results'),
          ),
          // ------------------------------------
          // --- CLICKABLE ADVICE BUTTON ---
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdviceScreen()), 
              );
            },
            child: _buildNavItem(icon: Icons.lightbulb_outline, label: 'Advice'),
          ),
          // -------------------------------
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
              ? BoxDecoration(color: AppColors.cardBgTint, borderRadius: BorderRadius.circular(12))
              : null,
          child: Icon(
            icon,
            color: isActive ? AppColors.actionCardBg : Colors.grey.shade500,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.actionCardBg : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }
}