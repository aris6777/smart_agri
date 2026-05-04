import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'results_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  
  //diretso dun sa firebase history folder and will be asking for the last 5 scans
  final Query _historyQuery = FirebaseDatabase.instance.ref('scanHistory').limitToLast(5);

  // --- CAMERA & GALLERY LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        // Send the image to your AI Results screen!
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(imageFile: File(pickedFile.path)),
          ),
        );
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  // Helper to format the ugly timestamp into a nice readable date
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Recent";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Plant Scanner", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TOP SECTION: SCAN BUTTONS ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(color: const Color(0xFF135A3B), borderRadius: BorderRadius.circular(20)),
                      child: const Column(
                        children: [
                          Icon(LucideIcons.camera, color: Colors.white, size: 40),
                          SizedBox(height: 12),
                          Text("Take Photo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE0E0E0))),
                      child: const Column(
                        children: [
                          Icon(LucideIcons.imagePlus, color: Color(0xFF135A3B), size: 40),
                          SizedBox(height: 12),
                          Text("Upload Gallery", style: TextStyle(color: const Color(0xFF135A3B), fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // --- DIVIDER ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text("Recent Scans", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D332F))),
          ),
          const SizedBox(height: 16),

          // --- BOTTOM SECTION: HISTORY LIST ---
          Expanded(
            child: StreamBuilder(
              stream: _historyQuery.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF81C784)));
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text("No scans yet. Take a photo to get started!", style: TextStyle(color: Colors.grey)),
                  );
                }

                // Convert Firebase data into a list
                Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<dynamic> historyList = map.values.toList();
                
                // Sort the list so the newest scan is at the top!
                historyList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    var item = historyList[index];
                    bool isHealthy = item['diagnosis'].toString().toLowerCase().contains('healthy');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          // Dynamic Icon based on AI result
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isHealthy ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                              color: isHealthy ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['diagnosis'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D332F))),
                                const SizedBox(height: 4),
                                Text(_formatDate(item['timestamp']), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(item['confidence'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF135A3B))),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}