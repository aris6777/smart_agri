import 'package:flutter/material.dart';
import 'scan_screen.dart';
import 'results_screen.dart';
import 'advice_screen.dart';
import 'dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
      messagingSenderId: "716254020181",
      projectId: "smartagridb",
      databaseURL: "https://smartagridb-default-rtdb.firebaseio.com",
    ),
  );

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
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF6F9F6),
        primaryColor: const Color(0xFF135A3B),
      ),
      home: const MainLayoutScreen(),
    );
  }
}

class AppColors {
  static const Color background = Color(0xFFF6F9F6);
  static const Color darkText = Color(0xFF003D33);
  static const Color tealText = Color(0xFF00695C);
  static const Color lightText = Color(0xFF757575);
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgTint = Color(0xFFF0F5F1);
  static const Color actionCardBg = Color(0xFF135A3B);
  static const Color accentGreen = Color(0xFFA5D6A7);
  static const Color alertRedBg = Color(0xFFFFE0B2);
  static const Color iconBgGreen = Color(0xFFC8E6C9);
  static const Color iconBgYellow = Color(0xFFE6EE9C);
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

// ---> HERE IS THE STATE CLASS WITH THE FIREBASE LISTENER <---
class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  int currentProblemCount = 0; // Starts at 0 until Firebase says otherwise

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ScanScreen(),
   ResultsScreen(
    liveN: 0,
    liveP: 0,
    liveK: 0,
    livePh: 0.0,
    liveMoisture: 0,
  ),
    const AdviceScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToSensorData(); // Start listening as soon as the app opens
  }

  void _listenToSensorData() {
    FirebaseDatabase.instance.ref('sensorData').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        int problems = 0;

        // Safely extract values using the EXACT names from your Firebase
        double moisture = (data['soilMoisture'] ?? 0).toDouble();
        double temp = (data['temperature'] ?? 0).toDouble();
        double ph = (data['phLevel'] ?? 0).toDouble();

        // Check against our thresholds
        if (moisture < 20.0) problems++; 
        if (temp < 15.0) problems++;     
        if (ph >= 0 && ph < 5.5) problems++; // Changed > to >= so it counts the 0!
        
        // Instantly update the red badge!
        setState(() {
          currentProblemCount = problems;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        problemCount: currentProblemCount,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final int problemCount;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.problemCount,
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
            child: _buildNavItem(icon: Icons.lightbulb_outline, label: 'Advice', isActive: currentIndex == 3, badgeCount: problemCount),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isActive, int badgeCount = 0}) {
    Widget iconWidget = Icon(
      icon,
      color: isActive ? const Color(0xFF135A3B) : Colors.grey.shade500,
      size: 24,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        child: iconWidget,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isActive ? 8.0 : 0.0),
          decoration: isActive
              ? BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(12))
              : null,
          child: iconWidget,
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