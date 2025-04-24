import 'dart:async';
import 'package:flutter/material.dart';
import 'card_board.dart';

void main() {
  runApp(RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: MyHomePage(),
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    final _RestartWidgetState? state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
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
            'Match two cards to score points. 1 pair match = 200 points',
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
                Timer(Duration(seconds: 0), runTimer);
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
    Timer(Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (score == 2000) {
          time = -2;
          score = 0;
        } else {
          time += 1;
          runTimer();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (init == 1) {
      init++;
      Future.delayed(Duration.zero, () => showAlert(context));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(),
        child: Column(
          children: <Widget>[
            SizedBox(height: 24.0),
            buildScore(),
            buildBoard(context),
          ],
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
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: CardBoard(onWin: onWin, context: context),
          ),
        ],
      ),
    );
  }

  void onWin() {
    setState(() {
      if (score == 2000) {
        time = 0;
      }
      score += 200;
    });
  }
}
