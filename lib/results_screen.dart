import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
      _runAIAnalysis(); // Trigger the real AI when the screen opens
    }
  }

  Future<void> _runAIAnalysis() async {
    // google studio API dito
    const apiKey = 'AIzaSyB2tfUgZU3Cuu2_kC1WJqpWnoTZOcd30Po'; 
    

    try {
      // 2. Initialize the Gemini Vision model
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // 3. Prepare the image and give Gemini strict instructions
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

      // 4. Send to Google's Cloud Servers
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);

      // 5. Parse the result to update the UI
      final output = response.text ?? "";
      
      setState(() {
        // Extracting the specific lines out of the AI's response
        diagnosis = _extractLine(output, "Disease:");
        confidence = _extractLine(output, "Confidence:");
        recommendation = _extractLine(output, "Recommendation:");
        isAnalyzing = false; // Turn off the loading spinner!
      });

    } catch (e) {
      print("AI Error: $e");
      setState(() {
        diagnosis = "Analysis Failed";
        recommendation = "Please check your internet connection and API key.";
        isAnalyzing = false;
      });
    }
  }

  // Helper function to cleanly chop up the text the AI sends back
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
                      const Text("Gemini AI is analyzing the leaf...", style: TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ] else ...[
                      Icon(
                        // Dynamically change the icon if it's healthy or sick
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