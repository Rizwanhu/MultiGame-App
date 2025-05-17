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
      id: '2048_512',
      title: 'Merge 512 Tile in 2048',
      description: 'Reach 512 tile in the 2048 Game',
      reward: 35,
      targetValue: 512,
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

        for (var challenge in activeChallenges) {
          userProgress.putIfAbsent(challenge.id, () => 0);
        }
      }
    } catch (e) {
      print('Error loading challenges: $e');
    }

    // Verify challenges after loading
    await _verifyAllChallenges();
    
    setState(() => isLoading = false);
  }

  Future<void> _verifyAllChallenges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    bool anyProgressUpdated = false;
    
    for (var challenge in activeChallenges) {
      // Skip already claimed challenges
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
  }

  Future<void> _generateNewChallenges(String userId) async {
    final random = Random();
    final availableChallenges = List<Challenge>.from(allChallenges)..shuffle(random);

    activeChallenges = availableChallenges.take(3).toList();
    userProgress = { for (var c in activeChallenges) c.id: 0 };

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
          // Find highest score in CardFlipper
          final cardFlipperDocs = history.docs.where(
              (doc) => doc.data()['source'] == 'CardFlipper');
          int highestScore = 0;
          for (var doc in cardFlipperDocs) {
            final score = doc.data()['score'] ?? 0;
            if (score > highestScore) highestScore = score;
          }
          return highestScore;
          
        case ChallengeType.snakeScore:
          // Find highest score in Snake
          final snakeDocs = history.docs.where(
              (doc) => doc.data()['source'] == 'Snake');
          int highestScore = 0;
          for (var doc in snakeDocs) {
            final score = doc.data()['score'] ?? 0;
            if (score > highestScore) highestScore = score;
          }
          return highestScore;
          
        case ChallengeType.mergeTile2048:
          // Find highest tile in 2048
          final game2048Docs = history.docs.where(
              (doc) => doc.data()['source'] == '2048');
          int highestTile = 0;
          for (var doc in game2048Docs) {
            final details = doc.data()['details'] as String?;
            if (details != null && details.contains('Reached tile:')) {
              final tileStr = details.split('Reached tile:')[1].trim();
              final tile = int.tryParse(tileStr) ?? 0;
              if (tile > highestTile) highestTile = tile;
            }
          }
          return highestTile;
          
        case ChallengeType.cardFlipperGames:
          // Count CardFlipper games played
          return history.docs.where((doc) =>
              doc.data()['source'] == 'CardFlipper').length;
              
        case ChallengeType.ticTacToeDraws:
          // Count Tic Tac Toe draws
          return history.docs.where((doc) =>
              doc.data()['source'] == 'TicTacToe' && 
              (doc.data()['details'] as String?)?.contains('Draw') == true).length;
              
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

    try {
      final relevantChallenges = activeChallenges.where((c) => c.type == type).toList();
      if (relevantChallenges.isEmpty) return;

      // Update progress for all relevant challenges
      Map<String, int> updatedProgress = Map.from(userProgress);
      bool hasChanges = false;
      
      for (var challenge in relevantChallenges) {
        // Skip already claimed challenges
        if (updatedProgress[challenge.id] == -1) continue;
        
        final currentProgress = updatedProgress[challenge.id] ?? 0;
        int newProgress;
        
        // For cumulative challenges, add to the progress
        if (type == ChallengeType.cardFlipperGames || 
            type == ChallengeType.ticTacToeDraws) {
          newProgress = currentProgress + amount;
        } else {
          // For high score challenges, update if the new amount is higher
          newProgress = amount > currentProgress ? amount : currentProgress;
        }
        
        if (newProgress != currentProgress) {
          updatedProgress[challenge.id] = newProgress;
          hasChanges = true;
        }
      }
      
      // Save the updated progress if changed
      if (hasChanges) {
        await _firestore.collection('users').doc(user.uid).update({
          'challengeProgress': updatedProgress,
        });
        
        setState(() {
          userProgress = updatedProgress;
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
      // Verify the challenge is actually completed before claiming
      final progress = await _calculateChallengeProgress(challenge);
      if (progress < challenge.targetValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Challenge not completed yet!'))
        );
        return;
      }
      
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

      final userDoc = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentScore = snapshot.data()?['score'] ?? 0;

        transaction.update(userDoc, {
          'score': currentScore + challenge.reward,
          'challengeProgress.${challenge.id}': -1,
        });

        final historyRef = userDoc.collection('scoreHistory').doc();
        transaction.set(historyRef, {
          'score': challenge.reward,
          'source': 'Challenge',
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Completed challenge: ${challenge.title}'
        });
      });

      setState(() {
        userProgress[challenge.id] = -1;
      });

      final allCompleted = activeChallenges.every((c) => 
          (userProgress[c.id] ?? 0) == -1);

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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                  value: isClaimed
                                      ? 1.0
                                      : (isCompleted ? 1.0 : progress / challenge.targetValue.toDouble()),
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isClaimed ? 'Claimed' : '$progress/${challenge.targetValue}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                    if (!isClaimed)
                                      ElevatedButton(
                                        onPressed: isCompleted 
                                            ? () => _claimReward(challenge) 
                                            : () async {
                                                // Refresh the progress on button click
                                                final newProgress = await _calculateChallengeProgress(challenge);
                                                
                                                if (newProgress != progress) {
                                                  setState(() {
                                                    userProgress[challenge.id] = newProgress;
                                                  });
                                                  
                                                  await _firestore.collection('users').doc(
                                                      FirebaseAuth.instance.currentUser?.uid
                                                  ).update({
                                                    'challengeProgress.${challenge.id}': newProgress,
                                                  });
                                                }
                                                
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(
                                                    newProgress >= challenge.targetValue
                                                        ? 'Challenge completed! Claim your reward!'
                                                        : 'Progress updated (${newProgress}/${challenge.targetValue})'
                                                  ))
                                                );
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          isCompleted ? 'Claim Reward' : 'Check Progress',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      )
                                    else
                                      Text('Reward Claimed', style: TextStyle(color: Colors.green)),
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
      type: ChallengeType.values.firstWhere((e) => e.toString() == map['type']),
    );
  }
}