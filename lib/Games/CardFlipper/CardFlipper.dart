import 'dart:async';
import 'package:flutter/material.dart';
import 'card_board.dart';
import '../../screen/main_screen.dart';
import '../../services/auth_service.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';


class CardFlipperGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int? score;
  final int? time;

  const MyHomePage({Key? key, this.score, this.time}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int score = 0;
  int time = 0;
  int init = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    init = 1;
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Welcome to Card Flipper',
            style: TextStyle(
              fontSize: 28.0,
              fontFamily: 'GoogleSans',
              color: Colors.black,
            ),
          ),
          content: Text(
            'Match two cards to score points. 1 pair match = 20 points (max 200)',
            style: TextStyle(
              fontSize: 22.0,
              fontFamily: 'GoogleSans',
              color: Colors.grey,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                runTimer();
              },
              child: Text(
                " Let's play !",
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'GoogleSans',
                  color: Colors.purple,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void runTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        time += 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void onWin() {
    setState(() {
      if (score < 200) {
        score += 20;
        if (score > 200) score = 200;
      }
    });
  }

  void onGameEnd() async {
    _timer?.cancel();

    // Update Firebase score
    final user = AuthService().currentUser;
    if (user != null) {
      final docRef = AuthService().firestore.collection('users').doc(user.uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final currentScore = snapshot.data()?['score'] ?? 0;
        
        // Update main score
        transaction.update(docRef, {'score': currentScore + score});
        
        // Add to score history with details
        final historyRef = docRef.collection('scoreHistory').doc();
        transaction.set(historyRef, {
          'score': score,
          'source': 'Card Flipper Game',
          'timestamp': FieldValue.serverTimestamp(),
          'details': 'Time taken: ${time}s | Score: $score | Max possible: 200'
        });
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over!"),
        content: Text("Total Time: ${time}s\nTotal Score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            },
            child: Text("Back to Home"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (init == 1) {
      init++;
      Future.delayed(Duration.zero, () => showAlert(context));
    }
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Card Flipper'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _timer?.cancel();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                (route) => false,
              );
            },
          ),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 24.0),
              buildScore(),
              buildBoard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScore() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "$time s",
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontFamily: 'GoogleSans',
            ),
          ),
          Text(
            "Score: $score",
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontFamily: 'GoogleSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBoard(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: CardBoard(onWin: onWin, context: context, onGameEnd: onGameEnd),
      ),
    );
  }
}
