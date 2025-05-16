import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  // Static method to track events from other screens
  static void trackEvent(BuildContext context, ChallengeType type, {int amount = 1}) {
    final state = context.findAncestorStateOfType<_ChallengesScreenState>();
    state?._updateChallengeProgress(type, amount);
  }

  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final List<Challenge> allChallenges = [
    Challenge(
      id: '1',
      title: 'Score 100 Points',
      description: 'Reach 100 points in any game',
      reward: 20,
      targetValue: 100,
      type: ChallengeType.score,
    ),
    Challenge(
      id: '2',
      title: 'Play 3 Games',
      description: 'Complete 3 game sessions',
      reward: 30,
      targetValue: 3,
      type: ChallengeType.gamesPlayed,
    ),
    Challenge(
      id: '3',
      title: 'Make a 2048 Tile',
      description: 'Merge tiles to create a 2048 tile',
      reward: 100,
      targetValue: 2048,
      type: ChallengeType.tileMerge,
    ),
    Challenge(
      id: '4',
      title: 'Daily Login',
      description: 'Open the app today',
      reward: 10,
      targetValue: 1,
      type: ChallengeType.dailyLogin,
    ),
    Challenge(
      id: '5',
      title: 'Win 2 Matches',
      description: 'Win 2 games in any mode',
      reward: 50,
      targetValue: 2,
      type: ChallengeType.wins,
    ),
  ];

  List<Challenge> activeChallenges = [];
  bool isLoading = true;
  Map<String, int> userProgress = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (!doc.exists || 
          (doc.data()?['challengesLastUpdated'] as Timestamp?)?.toDate().isBefore(today) == true) {
        await _generateNewChallenges(user.uid);
      } else {
        final challengesData = List<Map<String, dynamic>>.from(
            doc.data()?['activeChallenges'] ?? []);
        activeChallenges = challengesData
            .map((data) => Challenge.fromMap(data))
            .where((c) => allChallenges.any((ac) => ac.id == c.id))
            .toList();

        userProgress = Map<String, int>.from(
            doc.data()?['challengeProgress'] ?? {});

        // Initialize progress for new challenges
        for (var challenge in activeChallenges) {
          userProgress.putIfAbsent(challenge.id, () => 0);
        }
      }
    } catch (e) {
      print('Error loading challenges: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _generateNewChallenges(String userId) async {
    final random = Random();
    final availableChallenges = allChallenges.where((c) {
      return !activeChallenges.any((ac) => ac.id == c.id);
    }).toList();

    activeChallenges = [];
    userProgress = {};

    while (activeChallenges.length < 3 && availableChallenges.isNotEmpty) {
      final index = random.nextInt(availableChallenges.length);
      final challenge = availableChallenges[index];
      activeChallenges.add(challenge);
      availableChallenges.removeAt(index);
      userProgress[challenge.id] = 0;
    }

    await _saveChallenges(userId);
  }

  Future<void> _saveChallenges(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'activeChallenges': activeChallenges.map((c) => c.toMap()).toList(),
        'challengeProgress': userProgress,
        'challengesLastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving challenges: $e');
    }
  }

  Future<void> _updateChallengeProgress(ChallengeType type, int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || amount <= 0) return;

    try {
      final relevantChallenges = activeChallenges.where((c) => c.type == type);
      if (relevantChallenges.isEmpty) return;

      final updates = <String, dynamic>{};
      bool needsRefresh = false;

      for (var challenge in relevantChallenges) {
        final currentProgress = userProgress[challenge.id] ?? 0;
        if (currentProgress == -1) continue; // Already claimed
        
        final newProgress = min(currentProgress + amount, challenge.targetValue);
        updates['challengeProgress.${challenge.id}'] = newProgress;

        if (newProgress >= challenge.targetValue && currentProgress < challenge.targetValue) {
          needsRefresh = true;
        }
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
        
        // Update local state
        setState(() {
          updates.forEach((key, value) {
            final challengeId = key.replaceFirst('challengeProgress.', '');
            userProgress[challengeId] = value;
          });
        });
      }
    } catch (e) {
      print('Error updating challenge progress: $e');
    }
  }

  Future<void> _claimReward(Challenge challenge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Show reward dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reward Claimed!'),
          content: Text('You earned ${challenge.reward} points!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Update user score and mark challenge as claimed
      await _firestore.collection('users').doc(user.uid).update({
        'score': FieldValue.increment(challenge.reward),
        'challengeProgress.${challenge.id}': -1,
      });

      // Update local state
      setState(() {
        userProgress[challenge.id] = -1;
      });

      // Check if all challenges are completed
      final allCompleted = activeChallenges.every((c) => 
          (userProgress[c.id] ?? 0) >= c.targetValue);

      if (allCompleted) {
        await _generateNewChallenges(user.uid);
      }
    } catch (e) {
      print('Error claiming reward: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Missions'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete missions to earn rewards!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activeChallenges.length,
                      itemBuilder: (context, index) {
                        final challenge = activeChallenges[index];
                        final progress = userProgress[challenge.id] ?? 0;
                        final isCompleted = progress >= challenge.targetValue;
                        final isClaimed = progress == -1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      challenge.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '+${challenge.reward} pts',
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  challenge.description,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: isCompleted
                                      ? 1.0
                                      : progress / challenge.targetValue,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.deepPurple),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$progress/${challenge.targetValue}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: isCompleted && !isClaimed
                                          ? () => _claimReward(challenge)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        isClaimed ? 'Claimed' : 'Claim Reward',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

enum ChallengeType {
  score,
  gamesPlayed,
  tileMerge,
  dailyLogin,
  wins,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int reward;
  final int targetValue;
  final ChallengeType type;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.targetValue,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'targetValue': targetValue,
      'type': type.toString(),
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      targetValue: map['targetValue'],
      type: ChallengeType.values.firstWhere(
          (e) => e.toString() == map['type']),
    );
  }
}