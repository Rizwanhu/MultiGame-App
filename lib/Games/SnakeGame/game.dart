import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'control_panel.dart';
import 'direction.dart';
import 'direction_type.dart';
import 'piece.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<Game> {
  List<Offset> positions = [];
  int length = 5;
  int step = 20;
  Direction direction = Direction.right;

  Offset? foodPosition;

  double screenWidth = 0;
  double screenHeight = 0;
  int lowerBoundX = 0, upperBoundX = 0, lowerBoundY = 0, upperBoundY = 0;

  Timer? timer;
  double speed = 0.05;

  int score = 0;

  @override
  void initState() {
    super.initState();
    restart();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void draw() {
    if (positions.isEmpty) {
      positions.add(getRandomPositionWithinRange());
    }

    while (length > positions.length) {
      positions.add(positions.last);
    }

    for (int i = positions.length - 1; i > 0; i--) {
      positions[i] = positions[i - 1];
    }
    positions[0] = getNextPosition(positions[0]);
  }

  Direction getRandomDirection([DirectionType? type]) {
    if (type == DirectionType.horizontal) {
      return Random().nextBool() ? Direction.right : Direction.left;
    } else if (type == DirectionType.vertical) {
      return Random().nextBool() ? Direction.up : Direction.down;
    } else {
      return Direction.values[Random().nextInt(4)];
    }
  }

  Offset getRandomPositionWithinRange() {
    int posX = Random().nextInt((upperBoundX - lowerBoundX) ~/ step) * step + lowerBoundX;
    int posY = Random().nextInt((upperBoundY - lowerBoundY) ~/ step) * step + lowerBoundY;
    return Offset(posX.toDouble(), posY.toDouble());
  }

  bool detectCollision(Offset position) {
    return (position.dx >= upperBoundX && direction == Direction.right) ||
        (position.dx <= lowerBoundX && direction == Direction.left) ||
        (position.dy >= upperBoundY && direction == Direction.down) ||
        (position.dy <= lowerBoundY && direction == Direction.up);
  }

  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.black,
                width: 3.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Game Over",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Your game is over but you played well. Your score is $score.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restart();
              },
              child: Text(
                "Restart",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Offset getNextPosition(Offset position) {
    if (detectCollision(position)) {
      timer?.cancel();
      Future.delayed(Duration(milliseconds: 500), showGameOverDialog);
      return position;
    }

    switch (direction) {
      case Direction.right:
        return Offset(position.dx + step, position.dy);
      case Direction.left:
        return Offset(position.dx - step, position.dy);
      case Direction.up:
        return Offset(position.dx, position.dy - step);
      case Direction.down:
        return Offset(position.dx, position.dy + step);
    }
  }

  void drawFood() {
    foodPosition ??= getRandomPositionWithinRange();

    if (foodPosition == positions[0]) {
      length++;
      speed += 0.05;
      score += 5;
      changeSpeed();
      foodPosition = getRandomPositionWithinRange();
    }
  }

  List<Piece> getPieces() {
    draw();
    drawFood();

    return List.generate(length, (i) {
      if (i >= positions.length) return Piece(posX: 0, posY: 0, size: step, color: Colors.transparent);
      return Piece(
        posX: positions[i].dx.toInt(),
        posY: positions[i].dy.toInt(),
        size: step,
        color: Colors.red,
      );
    });
  }

  Widget getControls() {
    return ControlPanel(
      onTapped: (Direction newDirection) {
        if ((direction == Direction.left && newDirection == Direction.right) ||
            (direction == Direction.right && newDirection == Direction.left) ||
            (direction == Direction.up && newDirection == Direction.down) ||
            (direction == Direction.down && newDirection == Direction.up)) {
          return;
        }
        direction = newDirection;
      },
    );
  }

  int roundToNearestTens(int num) {
    int output = (num ~/ step) * step;
    return output == 0 ? step : output;
  }

  void changeSpeed() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: (200 ~/ speed).toInt()), (timer) {
      setState(() {});
    });
  }

  Widget getScore() {
    return Positioned(
      top: 50.0,
      right: 40.0,
      child: Text(
        "Score: $score",
        style: TextStyle(fontSize: 24.0),
      ),
    );
  }

  void restart() {
    setState(() {
      score = 0;
      length = 5;
      positions = [];
      direction = getRandomDirection();
      speed = 0.5;
      foodPosition = null;
      changeSpeed();
    });
  }

  Widget getPlayAreaBorder() {
    return Positioned(
      top: lowerBoundY.toDouble(),
      left: lowerBoundX.toDouble(),
      child: Container(
        width: (upperBoundX - lowerBoundX + step).toDouble(),
        height: (upperBoundY - lowerBoundY + step).toDouble(),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    lowerBoundX = step;
    lowerBoundY = step;
    upperBoundX = roundToNearestTens(screenWidth.toInt() - step);
    upperBoundY = roundToNearestTens(screenHeight.toInt() - step);

    return Scaffold(
      body: Container(
        color: Color(0XFFF5BB00),
        child: Stack(
          children: [
            getPlayAreaBorder(),
            ...getPieces(),
            if (foodPosition != null)
              Piece(
                posX: foodPosition!.dx.toInt(),
                posY: foodPosition!.dy.toInt(),
                size: step,
                color: Color(0XFF8EA604),
                isAnimated: true,
              ),
            getControls(),
            getScore(),
          ],
        ),
      ),
    );
  }
}
