import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'results_screen.dart';
import 'advice_screen.dart';
import 'dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  // 1. Ensures Flutter is fully booted before talking to the internet
  WidgetsFlutterBinding.ensureInitialized();

  // 2. The Firebase Handshake
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA2dyKzbmIei8z1YHr17fE9bnBD1CGW04c",
      appId: "1:716254020181:web:b41a8e3fe79ac642800adc",
      messagingSenderId: "716254020181",
      projectId: "smartagridb",
      // database url to para alam kung san titingin
      databaseURL: "https://smartagridb-default-rtdb.firebaseio.com", 
    ),
  );

  // 3. Run the app
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
      home: const MainLayoutScreen(),
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

// ==========================================
// MASTER APP SHELL (NAVIGATION CONTROLLER)
// ==========================================
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  // This IndexedStack holds all your screens and remembers their state!
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScanScreen(),
    const ResultsScreen(),
    const AdviceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- SMOOTH FADE TRANSITION ---
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // How fast the fade happens
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens[_currentIndex], // The active screen
      ),
      // ------------------------------
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Instantly swaps the screen and moves the green highlight
          });
        },
      ),
    );
  }
}

// ==========================================
// UPGRADED DYNAMIC NAVIGATION BAR
// ==========================================
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
          GestureDetector(
            onTap: () => onTap(0),
            child: _buildNavItem(icon: Icons.dashboard, label: 'Dashboard', isActive: currentIndex == 0),
          ),
          GestureDetector(
            onTap: () => onTap(1),
            child: _buildNavItem(icon: Icons.document_scanner_outlined, label: 'Scan', isActive: currentIndex == 1),
          ),
          GestureDetector(
            onTap: () => onTap(2),
            child: _buildNavItem(icon: Icons.analytics_outlined, label: 'Results', isActive: currentIndex == 2),
          ),
          GestureDetector(
            onTap: () => onTap(3),
            child: _buildNavItem(icon: Icons.lightbulb_outline, label: 'Advice', isActive: currentIndex == 3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isActive ? 8.0 : 0.0),
          decoration: isActive
              ? BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(12))
              : null,
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF135A3B) : Colors.grey.shade500,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF135A3B) : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }
}
