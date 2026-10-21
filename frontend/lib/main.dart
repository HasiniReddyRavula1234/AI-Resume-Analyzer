import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AIResumeAnalyzerApp());
}

class AIResumeAnalyzerApp extends StatelessWidget {
  const AIResumeAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AnalyzerHomeScreen(),
    );
  }
}

class AnalyzerHomeScreen extends StatefulWidget {
  const AnalyzerHomeScreen({super.key});

  @override
  State<AnalyzerHomeScreen> createState() => _AnalyzerHomeScreenState();
}

class _AnalyzerHomeScreenState extends State<AnalyzerHomeScreen> {
  final TextEditingController _jdController = TextEditingController();
  PlatformFile? _pickedFile;
  bool _isAnalyzing = false;
  bool _hasResults = false;

  // Analysis result states
  int _atsScore = 0;
  List<dynamic> _missingKeywords = [];
  List<dynamic> _weakBullets = [];
  String _resumeSnippet = '';

  // Backend API URL (Use 10.0.2.2 for Android Emulator, or 127.0.0.1 for Web/Windows/Mac desktop)
  final String _backendUrl = 'http://127.0.0.1:8000/analyze';

  void _pickResumeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: kIsWeb, // Required for web file bytes loading
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.single;
      });
    }
  }

  Future<void> _startAnalysis() async {
    if (_jdController.text.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Job Description and pick a resume file.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _hasResults = false;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.fields['job_description'] = _jdController.text;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _pickedFile!.bytes!,
            filename: _pickedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _pickedFile!.path!,
            filename: _pickedFile!.name,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _atsScore = data['ats_score'];
          _missingKeywords = data['missing_keywords'];
          _weakBullets = data['weak_bullets'];
          _resumeSnippet = data['extracted_resume_snippet'];
          _hasResults = true;
        });
      } else {
        throw Exception('Server returned status code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to backend: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'AI Resume Analyzer & ATS Optimizer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Target Job Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _jdController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Paste the job requirements, responsibilities, and tech stack here...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '2. Upload Candidate Resume',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickResumeFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo.shade200),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.indigo.shade50.withOpacity(0.3),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_upload_outlined, color: Color(0xFF6366F1), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _pickedFile?.name ?? 'Upload PDF or DOCX Resume',
                                style: TextStyle(
                                  color: _pickedFile != null ? Colors.black87 : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : _startAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.analytics_outlined),
                        label: Text(
                          _isAnalyzing ? 'Analyzing via FastAPI Backend...' : 'Analyze ATS Compatibility',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Section
            if (_hasResults) ...[
              // Score Banner Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFF1E293B),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ATS Compatibility Score',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_atsScore% / 100%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Good Match • Minor Tweaks Needed',
                            style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: _atsScore / 100,
                              backgroundColor: Colors.white24,
                              color: const Color(0xFF34D399),
                              strokeWidth: 8,
                            ),
                          ),
                          Text(
                            '$_atsScore%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Missing Keywords Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Missing High-Priority Keywords',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _missingKeywords
                            .map((keyword) => Chip(
                                  label: Text(keyword.toString()),
                                  backgroundColor: Colors.orange.shade50,
                                  labelStyle: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.w500),
                                  side: BorderSide(color: Colors.orange.shade200),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Interactive "Fix-It" Studio Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_fix_high, color: Color(0xFF6366F1)),
                          SizedBox(width: 8),
                          Text(
                            'Interactive AI "Fix-It" Studio',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap "Apply Fix" to upgrade weak bullet points into high-impact statements.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ..._weakBullets.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.remove_circle_outline, color: Colors.red, size: 16),
                                    SizedBox(width: 6),
                                    Text('Original Bullet:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item['original'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                const Divider(height: 16),
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                                    SizedBox(width: 6),
                                    Text('AI Optimized Version:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item['improved'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Enhancement applied successfully!')),
                                      );
                                    },
                                    icon: const Icon(Icons.done, size: 14),
                                    label: const Text('Apply Fix', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}