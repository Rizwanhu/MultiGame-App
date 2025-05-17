import 'package:flutter/material.dart';
import '../audio_aware_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeHistoryScreen extends AudioAwareScreen {
  @override
  _ChallengeHistoryScreenState createState() => _ChallengeHistoryScreenState();
}

class _ChallengeHistoryScreenState extends AudioAwareScreenState<ChallengeHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  List<Map<String, dynamic>> historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('scoreHistory')
          .orderBy('timestamp', descending: true)
          .get();
          
      historyItems = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF0A1A1F) : const Color(0xFF0B7996);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Challenge History", style: TextStyle(color: Colors.white)),
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadHistoryData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : historyItems.isEmpty
              ? Center(
                  child: Text(
                    'No history available',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: historyItems.length,
                  itemBuilder: (context, index) {
                    final data = historyItems[index];
                    final score = data['score'] ?? 0;
                    final source = data['source'] ?? 'Unknown';
                    final details = data['details'];
                    final timestamp = (data['timestamp'] as Timestamp).toDate();

                    final Widget listContent = ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: score >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          score >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: score >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(
                        source,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        '${timestamp.day.toString().padLeft(2, '0')}/'
                        '${timestamp.month.toString().padLeft(2, '0')}/'
                        '${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:' 
                        '${timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      trailing: Text(
                        '${score >= 0 ? "+" : ""}$score',
                        style: TextStyle(
                          color: score >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );

                    final Widget historyCard = Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: details != null
                          ? ExpansionTile(
                              leading: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: score >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  score >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: score >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                source,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                '${timestamp.day.toString().padLeft(2, '0')}/'
                                '${timestamp.month.toString().padLeft(2, '0')}/'
                                '${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:' 
                                '${timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              trailing: Text(
                                '${score >= 0 ? "+" : ""}$score',
                                style: TextStyle(
                                  color: score >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Details:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        details,
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white60 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : listContent,
                    );

                    // Group the history items by date
                    if (index == 0 || !_isSameDay(
                        (historyItems[index - 1]['timestamp'] as Timestamp).toDate(),
                        timestamp)) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                              _formatDate(timestamp),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          historyCard,
                        ],
                      );
                    }

                    return historyCard;
                  },
                ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    
    if (_isSameDay(date, today)) {
      return 'Today';
    } else if (_isSameDay(date, yesterday)) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}