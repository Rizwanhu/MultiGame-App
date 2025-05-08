
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/Bottombar.dart';
import 'main_screen.dart';
import 'profile_screen.dart';
import 'ads_screen.dart';

class LeaderboardPage extends StatefulWidget {
  final int initialIndex;
  LeaderboardPage({this.initialIndex = 1});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int userScore = 0;
  late int currentIndex;

  final List<Map<String, dynamic>> scores = [
    {
      'name': 'Vic',
      'score': 409392,
      'image': 'https://i.pravatar.cc/100?img=1',
    },
    {
      'name': 'Ksenia',
      'score': 258339,
      'image': 'https://i.pravatar.cc/100?img=2',
    },
    {
      'name': 'Olesya',
      'score': 238784,
      'image': 'https://i.pravatar.cc/100?img=3',
    },
    {
      'name': 'Sasha',
      'score': 227632,
      'image': 'https://i.pravatar.cc/100?img=4',
    },
    {
      'name': 'Ilya',
      'score': 58732,
      'image': 'https://i.pravatar.cc/100?img=5',
    },
    {
      'name': 'nesakosha',
      'score': 25895,
      'image': 'https://i.pravatar.cc/100?img=6',
    },
    {
      'name': 'Player 7',
      'score': 5216,
      'image': 'https://i.pravatar.cc/100?img=7',
    },
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    fetchUserScore();
  }

  Future<void> fetchUserScore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('score')) {
          setState(() {
            userScore = data['score'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Score: $userScore',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_picture.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0)),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'High Score',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                    Divider(),
                    ...List.generate(scores.length, (index) {
                      final item = scores[index];
                      final isTopThree = index < 3;
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isTopThree
                              ? Colors.blue.shade100.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Text('${index + 1}', style: TextStyle(fontSize: 20, color: Colors.blue[900], fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            CircleAvatar(radius: 18, backgroundImage: NetworkImage(item['image'])),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(item['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                            Text('${item['score']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MainScreen()), (route) => false);
            } else if (index == 2) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => AdsScreen()), (route) => false);
            } else if (index == 3) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => ProfileScreen()), (route) => false);
            }
          },
        ),
      ),
    );
  }
}
