// challenges.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';

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
      title: 'Score 128+ in 2048',
      description: 'Score 128 or more points in 2048 Game',
      reward: 35,
      targetValue: 128,
      type: ChallengeType.score2048,
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
    _startMidnightTimer(); // Add midnight timer
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  Timer? _midnightTimer;

  void _startMidnightTimer() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () {
      _resetChallengesAtMidnight();
      // Set up daily timer for subsequent days
      _midnightTimer = Timer.periodic(Duration(days: 1), (_) {
        _resetChallengesAtMidnight();
      });
    });
  }

  Future<void> _resetChallengesAtMidnight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print('Resetting challenges at midnight...');
    
    try {
      await _generateNewChallenges(user.uid);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New daily challenges are now available!')),
        );
      }
    } catch (e) {
      print('Error resetting challenges at midnight: $e');
    }
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
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // Ensure user document exists
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      
      if (!docSnapshot.exists) {
        // Create user document if it doesn't exist
        await userDoc.set({
          'score': 0,
          'activeChallenges': [],
          'challengeProgress': {},
          'challengesLastUpdated': FieldValue.serverTimestamp(),
        });
      }

      final doc = await userDoc.get();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final data = doc.data() ?? {};
      final lastUpdated = (data['challengesLastUpdated'] as Timestamp?)?.toDate();
      
      // More precise day comparison - check if it's a new day
      bool isNewDay = false;
      if (lastUpdated == null) {
        isNewDay = true;
      } else {
        final lastUpdatedDay = DateTime(lastUpdated.year, lastUpdated.month, lastUpdated.day);
        isNewDay = lastUpdatedDay.isBefore(today);
      }

      print('Last updated: $lastUpdated, Today: $today, Is new day: $isNewDay');

      if (isNewDay || (data['activeChallenges'] as List?)?.isEmpty == true) {
        print('Generating new challenges for new day');
        await _generateNewChallenges(user.uid);
      } else {
        print('Loading existing challenges');
        final storedChallenges = List<Map<String, dynamic>>.from(data['activeChallenges'] ?? []);
        activeChallenges = storedChallenges
            .map((data) => Challenge.fromMap(data))
            .where((c) => allChallenges.any((ac) => ac.id == c.id))
            .toList();

        userProgress = Map<String, int>.from(data['challengeProgress'] ?? {});
        
        // Ensure all active challenges have progress entries
        for (var challenge in activeChallenges) {
          userProgress.putIfAbsent(challenge.id, () => 0);
        }
      }

      // Verify all challenges after loading
      await _verifyAllChallenges();
    } catch (e) {
      print('Error loading challenges: $e');
      // Fallback: generate new challenges if loading fails
      await _generateNewChallenges(user.uid);
    }

    setState(() => isLoading = false);
  }

  Future<void> _verifyAllChallenges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || activeChallenges.isEmpty) return;

    bool anyProgressUpdated = false;
    final updatedProgress = Map<String, int>.from(userProgress);

    for (var challenge in activeChallenges) {
      if (updatedProgress[challenge.id] == -1) continue; // Already claimed

      final progress = await _verifySingleChallenge(challenge);
      if (progress != updatedProgress[challenge.id]) {
        updatedProgress[challenge.id] = progress;
        anyProgressUpdated = true;
      }
    }

    if (anyProgressUpdated) {
      userProgress = updatedProgress;
      await _firestore.collection('users').doc(user.uid).update({
        'challengeProgress': userProgress,
      });
      setState(() {});
    }
  }

  Future<int> _verifySingleChallenge(Challenge challenge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      print('Verifying challenge ${challenge.id} for today: $startOfToday to $endOfToday');

      final historyQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scoreHistory')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday));

      final history = await historyQuery.get();
      
      print('Found ${history.docs.length} history entries for today');

      switch (challenge.type) {
        case ChallengeType.cardFlipperScore:
          return _getMaxScoreToday(history.docs, 'CardFlipper');
          
        case ChallengeType.snakeScore:
          return _getMaxScoreToday(history.docs, 'Snake');
          
        case ChallengeType.score2048:
          return _getMaxScoreToday(history.docs, '2048');
          
        case ChallengeType.cardFlipperGames:
          return _getGameCountToday(history.docs, 'CardFlipper');
          
        case ChallengeType.ticTacToeDraws:
          return _getDrawCountToday(history.docs);
          
        default:
          return 0;
      }
    } catch (e) {
      print('Error verifying challenge ${challenge.id}: $e');
      return 0;
    }
  }

  int _getMaxScoreToday(List<QueryDocumentSnapshot> docs, String source) {
    print('Checking max score for $source');
    int maxScore = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docSource = data['source'] as String?;
      print('Document source: $docSource, looking for: $source');
      if (docSource == source) {
        final score = (data['score'] as num?)?.toInt() ?? 0;
        print('Found score: $score for $source');
        if (score > maxScore) maxScore = score;
      }
    }
    print('Max score for $source: $maxScore');
    return maxScore;
  }

  int _getGameCountToday(List<QueryDocumentSnapshot> docs, String source) {
    print('Checking game count for $source');
    int count = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['source'] == source;
    }).length;
    print('Game count for $source: $count');
    return count;
  }

  int _getDrawCountToday(List<QueryDocumentSnapshot> docs) {
    return docs.where((d) {
      if (!(d.data() is Map)) return false;
      final data = d.data() as Map<String, dynamic>;
      return data['source'] == 'TicTacToe' && 
             (data['details'] as String?)?.contains('Draw') == true;
    }).length;
  }

  Future<void> _generateNewChallenges(String userId) async {
    try {
      final random = Random();
      final availableChallenges = List<Challenge>.from(allChallenges)..shuffle(random);

      activeChallenges = availableChallenges.take(3).toList();
      userProgress = {for (var c in activeChallenges) c.id: 0};

      print('Generated new challenges: ${activeChallenges.map((c) => c.title).toList()}');

      await _firestore.collection('users').doc(userId).update({
        'activeChallenges': activeChallenges.map((c) => c.toMap()).toList(),
        'challengeProgress': userProgress,
        'challengesLastUpdated': FieldValue.serverTimestamp(),
      });

      print('Challenges saved to Firebase');
    } catch (e) {
      print('Error generating new challenges: $e');
    }
  }

  Future<void> _updateChallengeProgress(ChallengeType type, int amount) async {
    print('Updating challenge progress: $type with amount: $amount');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || amount <= 0) return;

    final relevantChallenges = activeChallenges.where((c) => c.type == type).toList();
    if (relevantChallenges.isEmpty) return;

    // Always verify from history to ensure accuracy
    await _verifyAllChallenges();
  }

  Future<void> _claimReward(Challenge challenge) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Verify challenge completion before claiming
    final currentProgress = await _verifySingleChallenge(challenge);
    
    if (currentProgress < challenge.targetValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge not completed yet! Progress: $currentProgress/${challenge.targetValue}')),
      );
      return;
    }

    if (userProgress[challenge.id] == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reward already claimed!')),
      );
      return;
    }

    try {
      final docRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((txn) async {
        final snap = await txn.get(docRef);
        final data = snap.data() ?? {};
        final currentScore = data['score'] ?? 0;

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reward claimed! +${challenge.reward} points')),
      );

      // Check if all challenges are completed to generate new ones
      final allCompleted = activeChallenges.every((c) => userProgress[c.id] == -1);
      if (allCompleted) {
        await _generateNewChallenges(user.uid);
        setState(() {});
      }
    } catch (e) {
      print('Error claiming reward: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error claiming reward. Please try again.')),
      );
    }
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
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
          : activeChallenges.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No challenges available',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await _generateNewChallenges(user.uid);
                          }
                          setState(() => isLoading = false);
                        },
                        child: Text('Generate New Challenges'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Challenges',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                  Text(
                                    'Challenges reset daily at midnight with new random objectives',
                                    style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Today\'s Missions (${_formatTodayDate()})',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete daily missions to earn rewards!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
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
                                        Expanded(
                                          child: Text(
                                            c.title,
                                            style: const TextStyle(
                                                fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple[50],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '+${c.reward} pts',
                                            style: const TextStyle(
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(c.description, style: TextStyle(color: Colors.grey[600])),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: claimed ? 1 : (complete ? 1 : progress / c.targetValue),
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        claimed ? Colors.green : Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          claimed
                                              ? 'Reward Claimed ✓'
                                              : '$progress/${c.targetValue}',
                                          style: TextStyle(
                                            color: claimed ? Colors.green : null,
                                            fontWeight: claimed ? FontWeight.bold : null,
                                          ),
                                        ),
                                        if (!claimed)
                                          ElevatedButton(
                                            onPressed: complete
                                                ? () => _claimReward(c)
                                                : () async {
                                                    setState(() => isLoading = true);
                                                    await _verifyAllChallenges();
                                                    setState(() => isLoading = false);
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: complete ? Colors.green : Colors.deepPurple,
                                            ),
                                            child: Text(
                                              complete ? 'Claim Reward' : 'Check Progress',
                                              style: TextStyle(color: Colors.white),
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
  cardFlipperScore,
  cardFlipperGames,
  snakeScore,
  ticTacToeDraws,
  score2048,
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
