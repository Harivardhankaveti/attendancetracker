import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';

class AdminPostTimetableScreen extends StatefulWidget {
  const AdminPostTimetableScreen({Key? key}) : super(key: key);

  @override
  State<AdminPostTimetableScreen> createState() => _AdminPostTimetableScreenState();
}

class _AdminPostTimetableScreenState extends State<AdminPostTimetableScreen> {
  // Manual form state
  final _formKey = GlobalKey<FormState>();
  final _courseCodeController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _facultyNameController = TextEditingController();
  final _roomController = TextEditingController();
  String? _selectedBranch;
  String? _selectedSection;
  String? _selectedDay;
  final List<String> _branches = ['CSE', 'ECE', 'EEE', 'IT', 'MECH', 'CIVIL'];
  final List<String> _sections = ['A', 'B', 'C', 'D', 'E', 'F'];
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  // PDF Upload state
  bool _isUploadingPdf = false;
  String _pdfStatus = '';

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _facultyNameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _postManualTimetable() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null || _selectedSection == null || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // For manual, we can continue appending individual sessions to "timetable"
      await FirebaseConfig.firestore.collection('timetable').add({
        'branch': _selectedBranch,
        'section': _selectedSection,
        'dayOfWeek': _selectedDay,
        'courseCode': _courseCodeController.text,
        'courseName': _courseNameController.text,
        'facultyName': _facultyNameController.text,
        'room': _roomController.text,
        'startTime': '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
        'endTime': '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable posted successfully')),
      );

      // Clear form
      _courseCodeController.clear();
      _courseNameController.clear();
      _facultyNameController.clear();
      _roomController.clear();
      setState(() {
        _selectedBranch = null;
        _selectedSection = null;
        _selectedDay = null;
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 10, minute: 0);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _pickAndProcessPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isUploadingPdf = true;
          _pdfStatus = 'Parsing PDF text...';
        });

        List<int> bytes = result.files.single.bytes != null 
            ? result.files.single.bytes!.toList()
            : await File(result.files.single.path!).readAsBytes();

        PdfDocument document = PdfDocument(inputBytes: bytes);
        String text = PdfTextExtractor(document).extractText();
        document.dispose();

        setState(() {
          _pdfStatus = 'Structuring timetables...';
        });

        await _processExtractedText(text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF Uploaded and Processed!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPdf = false;
          _pdfStatus = '';
        });
      }
    }
  }

  Future<void> _processExtractedText(String text) async {
    final sectionRegex = RegExp(r'(CSE|ECE|EEE|IT|MECH|CIVIL)\s*[-_]?\s*([A-Z])', caseSensitive: false);
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    final lines = text.split('\n');
    String currentBranchSection = '';
    Map<String, Map<String, String>> currentSchedule = {};
    String currentDay = '';

    Map<String, Map<String, Map<String, String>>> parsedData = {};

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Match Section Title
      final sectionMatch = sectionRegex.firstMatch(line);
      if (sectionMatch != null) {
        if (currentBranchSection.isNotEmpty && currentSchedule.isNotEmpty) {
          parsedData[currentBranchSection] = Map.from(currentSchedule);
        }

        String branch = sectionMatch.group(1)!.toUpperCase();
        String section = sectionMatch.group(2)!.toUpperCase();
        currentBranchSection = '${branch}_$section';
        currentSchedule = {
          for (var day in days) day: {}
        };
        currentDay = '';
        continue;
      }

      // Identify Day
      final lowerLine = line.toLowerCase();
      bool foundDay = false;
      for (var day in days) {
        if (lowerLine.startsWith(day.toLowerCase())) {
          currentDay = day;
          line = line.substring(day.length).trim();
          foundDay = true;
          break;
        }
      }

      // Look for timeslot syntax (e.g. "09:00 - 10:00")
      if (currentDay.isNotEmpty && currentBranchSection.isNotEmpty && line.isNotEmpty) {
        final timeRegex = RegExp(r'(\d{1,2}[:.]\d{2}(?:\s*(?:AM|PM|am|pm))?)\s*[-to]+\s*(\d{1,2}[:.]\d{2}(?:\s*(?:AM|PM|am|pm))?)?');
        final timeMatch = timeRegex.firstMatch(line);
        if (timeMatch != null) {
           String timeSlot = timeMatch.group(0)!;
           String subject = line.replaceAll(timeSlot, '').trim();
           if(subject.isEmpty) subject = "Class";
           currentSchedule[currentDay]![timeSlot] = subject;
        } else {
           // Fallback when no precise timeslot is found
           if (!foundDay) {
              final existingCount = currentSchedule[currentDay]!.length;
              currentSchedule[currentDay]!['Slot ${existingCount + 1}'] = line;
           }
        }
      }
    }

    if (currentBranchSection.isNotEmpty && currentSchedule.isNotEmpty) {
       parsedData[currentBranchSection] = currentSchedule;
    }

    if (parsedData.isEmpty) {
      throw Exception('Could not identify any branch/section. PDF might not follow the format.');
    }

    // Upload to Firestore
    for (var entry in parsedData.entries) {
      String docId = entry.key;
      await FirebaseConfig.firestore.collection('timetables').doc(docId).set({
        'branch': docId.split('_')[0],
        'section': docId.split('_')[1],
        'schedule': entry.value,
        'uploadedBy': 'Admin',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.adminColor,
          title: const Text('Post Timetable', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Upload PDF', icon: Icon(Icons.picture_as_pdf)),
              Tab(text: 'Manual Entry', icon: Icon(Icons.edit)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPDFUploadTab(),
            _buildManualTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPDFUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.upload_file, size: 80, color: AppColors.adminColor),
          const SizedBox(height: 24),
          const Text(
            'Upload Timetable PDF',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload a PDF document containing multiple sections. The system will auto-parse and create records like "CSE A", "ECE B", etc.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 48),
          
          if (_isUploadingPdf)
            Column(
              children: [
                const CircularProgressIndicator(color: AppColors.adminColor),
                const SizedBox(height: 16),
                Text(_pdfStatus, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.folder_open, color: Colors.white),
                label: const Text(
                  'Select PDF File',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: _pickAndProcessPDF,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch & Section Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Branch & Section', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                      items: _branches.map((branch) => DropdownMenuItem(value: branch, child: Text(branch))).toList(),
                      onChanged: (value) => setState(() => _selectedBranch = value),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedSection,
                      decoration: const InputDecoration(labelText: 'Section', border: OutlineInputBorder()),
                      items: _sections.map((section) => DropdownMenuItem(value: section, child: Text('Section $section'))).toList(),
                      onChanged: (value) => setState(() => _selectedSection = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Course Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Course Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _courseCodeController,
                      decoration: const InputDecoration(labelText: 'Course Code', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _courseNameController,
                      decoration: const InputDecoration(labelText: 'Course Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _facultyNameController,
                      decoration: const InputDecoration(labelText: 'Faculty Name', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _roomController,
                      decoration: const InputDecoration(labelText: 'Room Number', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Day & Time Selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedDay,
                      decoration: const InputDecoration(labelText: 'Day', border: OutlineInputBorder()),
                      items: _days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                      onChanged: (value) => setState(() => _selectedDay = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTimePicker(label: 'Start', time: _startTime, onChanged: (t) => setState(() => _startTime = t))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTimePicker(label: 'End', time: _endTime, onChanged: (t) => setState(() => _endTime = t))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _postManualTimetable,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Text('Post Manual Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker({required String label, required TimeOfDay time, required Function(TimeOfDay) onChanged}) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) onChanged(t);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        child: Text(time.format(context)),
      ),
    );
  }
}
