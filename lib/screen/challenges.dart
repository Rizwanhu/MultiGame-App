import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<Map<String, dynamic>> allMissions = [
    {"task": "Play 1 Game", "reward": 50},
    {"task": "Win 2 Matches", "reward": 100},
    {"task": "Watch 1 Ad", "reward": 30},
    {"task": "Login Today", "reward": 20},
    {"task": "Score 100 Points", "reward": 70},
    {"task": "Refer a Friend", "reward": 120},
  ];

  List<Map<String, dynamic>> todayMissions = [];
  Set<int> completedIndexes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userDoc = await docRef.get();

    final lastDate = userDoc.data()?['lastChallengeDate'];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDate == null ||
        DateTime.tryParse(lastDate)?.isBefore(today) == true) {
      // Pick 3 new random challenges
      todayMissions = getRandomChallenges(3);
      completedIndexes.clear();

      await docRef.update({
        'dailyMissions': todayMissions,
        'completedChallenges': [],
        'lastChallengeDate': today.toIso8601String(),
      });
    } else {
      // Load saved dailyMissions
      todayMissions =
          List<Map<String, dynamic>>.from(userDoc.data()?['dailyMissions'] ?? []);
      completedIndexes = Set<int>.from(userDoc.data()?['completedChallenges'] ?? []);
    }

    setState(() => isLoading = false);
  }

  List<Map<String, dynamic>> getRandomChallenges(int count) {
    final random = Random();
    final shuffled = [...allMissions]..shuffle(random);
    return shuffled.take(count).toList();
  }

  Future<void> completeChallenge(int index) async {
    if (completedIndexes.contains(index)) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final reward = todayMissions[index]['reward'];
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userDoc = await docRef.get();
    final currentScore = userDoc.data()?['score'] ?? 0;

    completedIndexes.add(index);
    await docRef.update({
      'completedChallenges': completedIndexes.toList(),
      'score': currentScore + reward,
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Challenges"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: todayMissions.length,
              itemBuilder: (context, index) {
                final mission = todayMissions[index];
                final isCompleted = completedIndexes.contains(index);

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isCompleted ? Colors.grey[300] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted ? Colors.green : Colors.deepPurple,
                      size: 30,
                    ),
                    title: Text(
                      mission['task'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Text(
                      "+${mission['reward']} pts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    onTap: () => completeChallenge(index),
                  ),
                );
              },
            ),
    );
  }
}
