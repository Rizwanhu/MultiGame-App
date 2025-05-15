import 'package:flutter/material.dart';
import '../widgets/boardgridview.dart';
import '../models/game.dart';
import '../widgets/cellwidget.dart';
import '../constants.dart';
import '../models/data.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


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
  bool _isGameOver = false; //cause the game is never over!
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
      _game.moveLeft();
      checkGameOver();
    });
  }

  void moveRight() {
    setState(() {
      _game.moveRight();
      checkGameOver();
    });
  }

  void moveUp() {
    setState(() {
      _game.moveUp();
      checkGameOver();
    });
  }

  void moveDown() {
    setState(() {
      _game.moveDown();
      checkGameOver();
    });
  }

  void checkGameOver() {
    if (_game.isGameOver() && !_isGameOver) {
      _isGameOver = true;
      
      // To ensure we don't call this multiple times
      Future.delayed(Duration(milliseconds: 300), () {
        String title = "Game Over";
        int scoreEnd = _game.score;
        
        if (scoreEnd > bestScore) {
          saveScore(scoreEnd);
          title = "New High Score!";
          setState(() {
            bestScore = scoreEnd;
          });
        }
        
        // Show the game over dialog
        if (mounted) {
          Alert(
            context: context,
            type: AlertType.info,
            title: title,
            desc: "The game is over. Your score is $scoreEnd.",
            buttons: [
              DialogButton(
                child: Text(
                  "Close",
                  style: dialogTextStyle,
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              ),
              DialogButton(
                child: Text(
                  "New Game",
                  style: dialogTextStyle,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Delay starting new game slightly to avoid any state issues
                  Future.delayed(Duration(milliseconds: 100), () {
                    if (mounted) {
                      newGame();
                    }
                  });
                },
                gradient: backgroundGradient,
              )
            ],
            closeFunction: () {
              // Make sure we can show another dialog later if needed
              _isGameOver = true;
            },
          ).show();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fix List constructor
    List<CellWidget> _cellWidget = [];
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        _cellWidget.add(CellWidget(cell: _game.get(r, c), state: this));
      }
    }
    _queryData = MediaQuery.of(context);
    // Fix List constructor
    List<Widget> children = [];
    children.add(BoardGridWidget(this));
    children.addAll(_cellWidget);
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                top: 20.0,
                bottom: 15.0,
              ),
              child: Text(
                '2048',
                style: titleTextStyle,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Score Container
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: boxBackground,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      width: 130.0,
                      height: 64.0, // Increased from 60 to 64
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Score',
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 1), // Added small spacing
                          Text(
                            _game.score.toString(),
                            style: boxTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Best Container
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: boxBackground,
                      ),
                      width: 130.0,
                      height: 64.0, // Increased from 60 to 64
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Best',
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 1), // Added small spacing
                          Text(
                            bestScore.toString(),
                            style: boxTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Replace FlatButton with TextButton
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.all(0.0),
                ),
                child: Container(
                  width: 80.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: boxBackground,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.refresh,
                      color: textColor,
                      size: 42,
                    ),
                  ),
                ),
                onPressed: () {
                  newGame();
                },
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
                        if (detail.delta.distance == 0 || _isDragging) {
                          return;
                        }
                        _isDragging = true;
                        if (detail.delta.direction > 0) {
                          moveDown();
                        } else {
                          moveUp();
                        }
                      },
                      onVerticalDragEnd: (detail) {
                        _isDragging = false;
                      },
                      onVerticalDragCancel: () {
                        _isDragging = false;
                      },
                      onHorizontalDragUpdate: (detail) {
                        if (detail.delta.distance == 0 || _isDragging) {
                          return;
                        }
                        _isDragging = true;
                        if (detail.delta.direction > 0) {
                          moveLeft();
                        } else {
                          moveRight();
                        }
                      },
                      onHorizontalDragDown: (detail) {
                        _isDragging = false;
                      },
                      onHorizontalDragCancel: () {
                        _isDragging = false;
                      },
                      child: Stack(
                        children: children,
                      ),
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

  Size boardSize() {
    // Remove assert as we've properly initialized _queryData
    Size size = _queryData.size;
    // Fix num to double conversion
    double width = (size.width - gameMargin.left - gameMargin.right).toDouble();
    double ratio = size.width / size.height;
    if (ratio > 0.75) {
      width = size.height / 2;
    }
    return Size(width, width);
  }
}