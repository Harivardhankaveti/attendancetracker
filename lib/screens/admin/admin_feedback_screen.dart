import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/firebase_config.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  List<FeedbackData> _feedbacks = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, student, faculty

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    try {
      Query query = FirebaseConfig.firestore
          .collection('feedback')
          .orderBy('timestamp', descending: true);

      if (_filterType != 'all') {
        query = query.where('userType', isEqualTo: _filterType);
      }

      final feedbacksSnapshot = await query.get();

      List<FeedbackData> feedbacks = [];
      for (var doc in feedbacksSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        feedbacks.add(FeedbackData(
          id: doc.id,
          userName: data['userName'] ?? 'Anonymous',
          userType: data['userType'] ?? 'student',
          subject: data['subject'] ?? 'No Subject',
          message: data['message'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ));
      }

      setState(() {
        _feedbacks = feedbacks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading feedbacks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFeedback(String feedbackId) async {
    try {
      await FirebaseConfig.firestore.collection('feedback').doc(feedbackId).delete();
      _loadFeedbacks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.adminColor,
        title: const Text('Feedback Management', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Students', 'student'),
                const SizedBox(width: 8),
                _buildFilterChip('Faculty', 'faculty'),
              ],
            ),
          ),

          // Feedbacks List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadFeedbacks,
                    child: _feedbacks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.feedback, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No feedbacks yet'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _feedbacks.length,
                            itemBuilder: (context, index) {
                              return _buildFeedbackCard(_feedbacks[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String type) {
    final isSelected = _filterType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterType = type;
            _isLoading = true;
          });
          _loadFeedbacks();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.adminColor : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.adminColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackData feedback) {
    final color = feedback.userType == 'student' ? AppColors.primary : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feedback.userType == 'student' ? Icons.school : Icons.person,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        feedback.userType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Feedback'),
                        content: const Text('Are you sure you want to delete this feedback?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteFeedback(feedback.id);
                            },
                            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback.subject,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feedback.message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < feedback.rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      feedback.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${feedback.timestamp.day}/${feedback.timestamp.month}/${feedback.timestamp.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackData {
  final String id;
  final String userName;
  final String userType;
  final String subject;
  final String message;
  final double rating;
  final DateTime timestamp;

  FeedbackData({
    required this.id,
    required this.userName,
    required this.userType,
    required this.subject,
    required this.message,
    required this.rating,
    required this.timestamp,
  });
}
