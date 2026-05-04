import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_database/firebase_database.dart';

class ResultsScreen extends StatefulWidget {
  final File? imageFile;
  
  const ResultsScreen({Key? key, this.imageFile}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isAnalyzing = true;
  String diagnosis = "";
  String confidence = "";
  String recommendation = "";

  @override
  void initState() {
    super.initState();
    if (widget.imageFile != null) {
      _runAIAnalysis();
    }
  }

  Future<void> _runAIAnalysis() async {
    // Kukunin ang key mula sa .env file
    final apiKey = dotenv.env['GEMINI_API_KEY']; 
    
    if (apiKey == null || apiKey.isEmpty) {
      print('ALERT: API Key not found in .env file!');
      setState(() {
        diagnosis = "Analysis Failed";
        recommendation = "API Key missing. Please check .env file.";
        isAnalyzing = false;
      });
      return;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final imageBytes = await widget.imageFile!.readAsBytes();
      final prompt = TextPart('''
        You are an expert plant pathologist. Analyze this plant image. 
        If the image is not a plant, say "Not a plant" for the disease.
        Respond STRICTLY in this exact format with no other text:
        Disease: [Name of disease or 'Healthy']
        Confidence: [Percentage]
        Recommendation: [1-2 sentences on what to do to treat or care for it]
      ''');
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      final output = response.text ?? "";
      
      setState(() {
        diagnosis = _extractLine(output, "Disease:");
        confidence = _extractLine(output, "Confidence:");
        recommendation = _extractLine(output, "Recommendation:");
        isAnalyzing = false; 
      });

      // --- FIREBASE SAVE BLOCK ---
      // Isa-save lang sa history kapag successful ang scan
      if (!diagnosis.contains("Analysis Failed") && !diagnosis.contains("Unknown") && !diagnosis.contains("Not a plant")) {
        final DatabaseReference historyRef = FirebaseDatabase.instance.ref('scanHistory');
        historyRef.push().set({
          'diagnosis': diagnosis,
          'confidence': confidence,
          'timestamp': DateTime.now().toIso8601String(), 
        });
      }

    } catch (e) {
      print("AI Error: $e");
      setState(() {
        diagnosis = "Analysis Failed";
        recommendation = "Please check your internet connection.";
        isAnalyzing = false;
      });
    }
  }

  String _extractLine(String text, String prefix) {
    try {
      final lines = text.split('\n');
      final targetLine = lines.firstWhere((line) => line.startsWith(prefix), orElse: () => "");
      return targetLine.replaceAll(prefix, "").trim();
    } catch (e) {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Analysis Results", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: widget.imageFile == null
          ? const Center(child: Text("No image found.", style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(widget.imageFile!, height: 250, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 40),
                    
                    if (isAnalyzing) ...[
                      const CircularProgressIndicator(color: Color(0xFF81C784)),
                      const SizedBox(height: 24),
                      // Ito yung custom text mo!
                      const Text("analyzing...", style: TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ] else ...[
                      Icon(
                        diagnosis.toLowerCase().contains("healthy") ? Icons.check_circle_outline : Icons.warning_amber_rounded, 
                        color: diagnosis.toLowerCase().contains("healthy") ? const Color(0xFF81C784) : const Color(0xFFFFB74D), 
                        size: 64
                      ),
                      const SizedBox(height: 16),
                      Text(
                        diagnosis,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D332F)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text("AI Confidence: $confidence", style: const TextStyle(fontSize: 16, color: Color(0xFF81C784), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(16), 
                          border: Border.all(color: const Color(0xFFE0E0E0))
                        ),
                        child: Text(
                          recommendation, 
                          style: const TextStyle(height: 1.5, fontSize: 16, color: Colors.black87)
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
    );
  }
}