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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('scoreHistory') // Updated collection name
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong', style: TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No history available',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
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

              return Container(
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
                child: details != null ? ExpansionTile(
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
                ) : listContent,
              );
            },
          );
        },
      ),
    );
  }
}
