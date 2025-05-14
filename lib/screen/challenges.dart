import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<Map<String, dynamic>> allChallenges = [
    {"task": "Play 1 Game", "reward": 50},
    {"task": "Win 2 Matches", "reward": 100},
    {"task": "Watch 1 Ad", "reward": 30},
    {"task": "Login Today", "reward": 20},
    {"task": "Score 100 Points", "reward": 70},
    {"task": "Play for 10 Minutes", "reward": 60},
    {"task": "Complete 3 Levels", "reward": 90},
  ];

  List<Map<String, dynamic>> todaysChallenges = [];
  Set<int> completedIndexes = {};
  bool isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String uid;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final today = DateTime.now();
    final lastDateStr = doc.data()?['lastChallengeDate'];
    final completed = List.from(doc.data()?['completedChallenges'] ?? []);

    if (lastDateStr != null) {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null &&
          lastDate.day == today.day &&
          lastDate.month == today.month &&
          lastDate.year == today.year) {
        final savedIndexes = List.from(doc.data()?['todaysChallenges'] ?? []);
        todaysChallenges = savedIndexes
            .map((index) => allChallenges[index as int])
            .toList();
        completedIndexes = completed.map((e) => e as int).toSet();
      } else {
        await generateNewChallenges(today);
      }
    } else {
      await generateNewChallenges(today);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> generateNewChallenges(DateTime today) async {
    todaysChallenges = getRandomChallenges(3);
    final indexes = todaysChallenges.map((c) => allChallenges.indexOf(c)).toList();
    await _firestore.collection('users').doc(uid).set({
      'todaysChallenges': indexes,
      'completedChallenges': [],
      'lastChallengeDate': today.toIso8601String(),
    }, SetOptions(merge: true));
    completedIndexes.clear();
  }

  List<Map<String, dynamic>> getRandomChallenges(int count) {
    final shuffled = List<Map<String, dynamic>>.from(allChallenges)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  Future<void> completeChallenge(int index) async {
    if (completedIndexes.contains(index)) return;

    setState(() {
      completedIndexes.add(index);
    });

    final challenge = todaysChallenges[index];
    final reward = challenge['reward'];

    final docRef = _firestore.collection('users').doc(uid);
    final userDoc = await docRef.get();
    final currentScore = userDoc.data()?['score'] ?? 0;

    await docRef.update({
      'completedChallenges': completedIndexes.toList(),
      'score': currentScore + reward,
    });
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
              itemCount: todaysChallenges.length,
              itemBuilder: (context, index) {
                final mission = todaysChallenges[index];
                final isCompleted = completedIndexes.contains(index);

                return Opacity(
                  opacity: isCompleted ? 0.5 : 1.0,
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "+${mission['reward']} pts",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (isCompleted)
                            Icon(Icons.done, color: Colors.green, size: 18),
                        ],
                      ),
                      onTap: isCompleted
                          ? null
                          : () {
                              completeChallenge(index);
                            },
                    ),
                  ),
                );
              },
            ),
    );
  }
}