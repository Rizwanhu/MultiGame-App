// challenges.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

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
      id: 'cf_200',
      title: 'Score 200 in CardFlipper',
      description: 'Match cards to reach 200 points',
      reward: 20,
      targetValue: 200,
      type: ChallengeType.cardFlipperScore,
    ),
    Challenge(
      id: 'cf_10_games',
      title: 'Play CardFlipper 10 times',
      description: 'Play CardFlipper 10 times in total',
      reward: 30,
      targetValue: 10,
      type: ChallengeType.cardFlipperGames,
    ),
    Challenge(
      id: 'snake_70',
      title: 'Score 70 in Snake',
      description: 'Score 70 or more in Snake Game',
      reward: 25,
      targetValue: 70,
      type: ChallengeType.snakeScore,
    ),
    Challenge(
      id: 'ttt_draws',
      title: 'Draw 3 Tic Tac Toe Games',
      description: 'Play and draw 3 games in Tic Tac Toe',
      reward: 15,
      targetValue: 3,
      type: ChallengeType.ticTacToeDraws,
    ),
    Challenge(
      id: '2048_128',
      title: 'Merge 128 Tile in 2048',
      description: 'Reach 128 tile in the 2048 Game',
      reward: 35,
      targetValue: 128,
      type: ChallengeType.mergeTile2048,
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoading) {
      _verifyAllChallenges();
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final data = doc.data();
      final storedChallenges = List<Map<String, dynamic>>.from(data?['activeChallenges'] ?? []);
      final storedChallengeIds = storedChallenges.map((c) => c['id']).toSet();
      final currentChallengeIds = allChallenges.map((c) => c.id).toSet();
      final containsInvalid = storedChallengeIds.any((id) => !currentChallengeIds.contains(id));

      if (!doc.exists ||
          (data?['challengesLastUpdated'] as Timestamp?)?.toDate().isBefore(today) == true ||
          containsInvalid) {
        await _generateNewChallenges(user.uid);
      } else {
        activeChallenges = storedChallenges
            .map((data) => Challenge.fromMap(data))
            .where((c) => allChallenges.any((ac) => ac.id == c.id))
            .toList();

        userProgress = Map<String, int>.from(data?['challengeProgress'] ?? {});
        for (var challenge in activeChallenges) {
          userProgress.putIfAbsent(challenge.id, () => 0);
        }
      }
    } catch (e) {
      print('Error loading challenges: $e');
    }

    await _verifyAllChallenges();
    setState(() => isLoading = false);
  }

  Future<void> _verifyAllChallenges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool anyProgressUpdated = false;

    for (var challenge in activeChallenges) {
      if (userProgress[challenge.id] == -1) continue;

      final progress = await _calculateChallengeProgress(challenge);
      if (progress != userProgress[challenge.id]) {
        userProgress[challenge.id] = progress;
        anyProgressUpdated = true;
      }
    }

    if (anyProgressUpdated) {
      await _firestore.collection('users').doc(user.uid).update({
        'challengeProgress': userProgress,
      });
    }

    setState(() {});
  }

  Future<void> _generateNewChallenges(String userId) async {
    final random = Random();
    final availableChallenges = List<Challenge>.from(allChallenges)..shuffle(random);

    activeChallenges = availableChallenges.take(3).toList();
    userProgress = {for (var c in activeChallenges) c.id: 0};

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

  Future<int> _calculateChallengeProgress(Challenge challenge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      final history = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scoreHistory')
          .get();

      switch (challenge.type) {
        case ChallengeType.cardFlipperScore:
        case ChallengeType.snakeScore:
          final source = challenge.type == ChallengeType.cardFlipperScore ? 'CardFlipper' : 'Snake';
          int maxScore = 0;
          for (var doc in history.docs.where((d) => d.data()['source'] == source)) {
            final score = doc.data()['score'] ?? 0;
            if (score > maxScore) maxScore = score;
          }
          return maxScore;

        case ChallengeType.mergeTile2048:
          final docs = history.docs.where((d) => d.data()['source'] == '2048');
          int maxTile = 0;
          for (var doc in docs) {
            final details = doc.data()['details'] ?? '';
            final match = RegExp(r'Reached tile: (\d+)').firstMatch(details);
            if (match != null) {
              final value = int.tryParse(match.group(1)!);
              if (value != null && value > maxTile) {
                maxTile = value;
              }
            }
          }
          return maxTile;

        case ChallengeType.cardFlipperGames:
          return history.docs.where((d) => d.data()['source'] == 'CardFlipper').length;

        case ChallengeType.ticTacToeDraws:
          return history.docs.where((d) =>
              d.data()['source'] == 'TicTacToe' &&
              (d.data()['details'] as String?)?.contains('Draw') == true).length;

        default:
          return 0;
      }
    } catch (e) {
      print('Error calculating challenge progress: $e');
      return 0;
    }
  }

  Future<void> _updateChallengeProgress(ChallengeType type, int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || amount <= 0) return;

    final relevantChallenges = activeChallenges.where((c) => c.type == type).toList();
    if (relevantChallenges.isEmpty) return;

    final updatedProgress = Map<String, int>.from(userProgress);
    bool hasChanges = false;

    for (var challenge in relevantChallenges) {
      if (updatedProgress[challenge.id] == -1) continue;

      final current = updatedProgress[challenge.id] ?? 0;
      final next = type == ChallengeType.cardFlipperGames || type == ChallengeType.ticTacToeDraws
          ? current + amount
          : max(current, amount);

      if (next != current) {
        updatedProgress[challenge.id] = next;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _firestore.collection('users').doc(user.uid).update({
        'challengeProgress': updatedProgress,
      });

      setState(() {
        userProgress = updatedProgress;
      });
    }
  }

  Future<void> _claimReward(Challenge challenge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final progress = await _calculateChallengeProgress(challenge);
    if (progress < challenge.targetValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge not completed yet!')),
      );
      return;
    }

    if (userProgress[challenge.id] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reward already claimed!')),
      );
      return;
    }

    final docRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(docRef);
      final currentScore = snap['score'] ?? 0;

      txn.update(docRef, {
        'score': currentScore + challenge.reward,
        'challengeProgress.${challenge.id}': -1,
      });

      txn.set(docRef.collection('scoreHistory').doc(), {
        'score': challenge.reward,
        'source': 'Challenge',
        'timestamp': FieldValue.serverTimestamp(),
        'details': 'Completed: ${challenge.title}',
      });
    });

    setState(() {
      userProgress[challenge.id] = -1;
    });

    final allCompleted = activeChallenges.every((c) => userProgress[c.id] == -1);
    if (allCompleted) await _generateNewChallenges(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Missions'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => isLoading = true);
              await _verifyAllChallenges();
              setState(() => isLoading = false);
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Progress synced')));
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Complete missions to earn rewards!',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activeChallenges.length,
                      itemBuilder: (context, index) {
                        final c = activeChallenges[index];
                        final progress = userProgress[c.id] ?? 0;
                        final complete = progress >= c.targetValue;
                        final claimed = progress == -1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(c.title,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('+${c.reward} pts',
                                          style: const TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(c.description, style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: claimed ? 1 : (complete ? 1 : progress / c.targetValue),
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(claimed
                                        ? 'Claimed'
                                        : '$progress/${c.targetValue}'),
                                    if (!claimed)
                                      ElevatedButton(
                                        onPressed: complete
                                            ? () => _claimReward(c)
                                            : () async {
                                                final newProgress =
                                                    await _calculateChallengeProgress(c);
                                                if (newProgress != progress) {
                                                  setState(() {
                                                    userProgress[c.id] = newProgress;
                                                  });
                                                 final uid = FirebaseAuth.instance.currentUser?.uid;
if (uid != null) {
  await _firestore
      .collection('users')
      .doc(uid)
      .update({'challengeProgress.${c.id}': newProgress});
}

                                                }

                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                  content: Text(
                                                    newProgress >= c.targetValue
                                                        ? 'Challenge completed!'
                                                        : 'Progress updated',
                                                  ),
                                                ));
                                              },
                                        child: Text(
                                            complete ? 'Claim Reward' : 'Check Progress'),
                                      )
                                    else
                                      const Text('Reward Claimed',
                                          style: TextStyle(color: Colors.green))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

enum ChallengeType {
  cardFlipperScore,
  cardFlipperGames,
  snakeScore,
  ticTacToeDraws,
  mergeTile2048,
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'reward': reward,
        'targetValue': targetValue,
        'type': type.toString(),
      };

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      targetValue: map['targetValue'],
      type: ChallengeType.values
          .firstWhere((e) => e.toString() == map['type']),
    );
  }
}
