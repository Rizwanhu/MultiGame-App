import 'package:flutter/material.dart';
import '../widgets/boardgridview.dart';
import '../models/game.dart';
import '../widgets/cellwidget.dart';
import '../constants.dart';
import '../models/data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../screen/main_screen.dart';
import '../../../../screen/challenges.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(),
    );
  }
}

class GameWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GameWidgetState();
  }
}

class GameWidgetState extends State<GameWidget> {
  late Game _game;
  late MediaQueryData _queryData;

  final int row = 4;
  final int column = 4;
  final double cellPadding = 5.0;
  bool _isDragging = false;
  bool _isGameOver = false;
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    _readBestScore();
    _game = Game(row, column);
    newGame();
  }

  _readBestScore() async {
    dynamic res = await readScore();
    setState(() {
      bestScore = res;
    });
  }

  void newGame() {
    _game.init();
    _isGameOver = false;
    setState(() {});
  }

  void moveLeft() {
    setState(() {
      int oldScore = _game.score;
      _game.moveLeft();
      _trackScoreUpdate(oldScore);
      checkGameOver();
    });
  }

  void moveRight() {
    setState(() {
      int oldScore = _game.score;
      _game.moveRight();
      _trackScoreUpdate(oldScore);
      checkGameOver();
    });
  }

  void moveUp() {
    setState(() {
      int oldScore = _game.score;
      _game.moveUp();
      _trackScoreUpdate(oldScore);
      checkGameOver();
    });
  }

  void moveDown() {
    setState(() {
      int oldScore = _game.score;
      _game.moveDown();
      _trackScoreUpdate(oldScore);
      checkGameOver();
    });
  }

  void _trackScoreUpdate(int oldScore) {
    if (_game.score > oldScore && context.mounted) {
      ChallengesScreen.trackEvent(context, ChallengeType.score2048, amount: _game.score);
    }
  }

  void checkGameOver() {
    if (_game.isGameOver() && !_isGameOver) {
      _isGameOver = true;

      Future.delayed(Duration(milliseconds: 300), () async {
        String title = "Game Over";
        int scoreEnd = _game.score;

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final snapshot = await transaction.get(docRef);
            final currentScore = snapshot.data()?['score'] ?? 0;

            transaction.update(docRef, {'score': currentScore + scoreEnd});

            final historyRef = docRef.collection('scoreHistory').doc();
            transaction.set(historyRef, {
              'score': scoreEnd,
              'source': '2048',
              'timestamp': FieldValue.serverTimestamp(),
              'details': 'Final Score: $scoreEnd | Best Score: $bestScore'
            });
          });

          if (mounted && context.mounted) {
            if (scoreEnd > 0) {
              ChallengesScreen.trackEvent(context, ChallengeType.score2048, amount: scoreEnd);
            }
          }
        }

        if (scoreEnd > bestScore) {
          saveScore(scoreEnd);
          title = "New High Score!";
          setState(() {
            bestScore = scoreEnd;
          });
        }

        if (mounted) {
          Alert(
            context: context,
            type: AlertType.info,
            title: title,
            desc: "The game is over. Your score is $scoreEnd.",
            buttons: [
              DialogButton(
                child: Text("Close", style: dialogTextStyle),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(); // Close alert
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                },
                width: 120,
              ),
              DialogButton(
                child: Text("New Game", style: dialogTextStyle),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(); // Close alert
                  setState(() {
                    _isGameOver = false;
                    newGame();
                  });
                },
                gradient: backgroundGradient,
              )
            ],
          ).show();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CellWidget> _cellWidget = [];
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        _cellWidget.add(CellWidget(cell: _game.get(r, c), state: this));
      }
    }
    _queryData = MediaQuery.of(context);
    List<Widget> children = [BoardGridWidget(this)]..addAll(_cellWidget);
    return Container(
      decoration: BoxDecoration(gradient: backgroundGradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
              child: Text('2048', style: titleTextStyle),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _scoreBox('Score', _game.score),
                _scoreBox('Best', bestScore),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Container(
                  width: 80.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: boxBackground,
                  ),
                  child: Center(
                    child: Icon(Icons.refresh, color: textColor, size: 42),
                  ),
                ),
                onPressed: newGame,
              ),
            ),
            Expanded(
              child: Container(
                margin: gameMargin,
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    width: boardSize().width,
                    height: boardSize().width,
                    child: GestureDetector(
                      onVerticalDragUpdate: (detail) {
                        if (detail.delta.distance == 0 || _isDragging) return;
                        _isDragging = true;
                        detail.delta.direction > 0 ? moveDown() : moveUp();
                      },
                      onVerticalDragEnd: (_) => _isDragging = false,
                      onVerticalDragCancel: () => _isDragging = false,
                      onHorizontalDragUpdate: (detail) {
                        if (detail.delta.distance == 0 || _isDragging) return;
                        _isDragging = true;
                        detail.delta.direction > 0 ? moveLeft() : moveRight();
                      },
                      onHorizontalDragDown: (_) => _isDragging = false,
                      onHorizontalDragCancel: () => _isDragging = false,
                      child: Stack(children: children),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreBox(String title, int score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: boxBackground,
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: 130.0,
        height: 64.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title, style: TextStyle(color: textColor)),
            SizedBox(height: 1),
            Text(score.toString(), style: boxTextStyle),
          ],
        ),
      ),
    );
  }

  Size boardSize() {
    Size size = _queryData.size;
    double width = (size.width - gameMargin.left - gameMargin.right).toDouble();
    double ratio = size.width / size.height;
    if (ratio > 0.75) width = size.height / 2;
    return Size(width, width);
  }
}
