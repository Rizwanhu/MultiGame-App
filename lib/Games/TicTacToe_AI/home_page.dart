import 'dart:math';
import 'package:flutter/material.dart';
import './custom_dailog.dart';
import './game_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<GameButton> buttonsList;
  var player1 = <int>[];
  var player2 = <int>[];
  var activePlayer;

  @override
  void initState() {
    super.initState();
    buttonsList = doInit();
  }

  List<GameButton> doInit() {
    player1 = [];
    player2 = [];
    activePlayer = 1;

    var gameButtons = <GameButton>[
      new GameButton(id: 1),
      new GameButton(id: 2),
      new GameButton(id: 3),
      new GameButton(id: 4),
      new GameButton(id: 5),
      new GameButton(id: 6),
      new GameButton(id: 7),
      new GameButton(id: 8),
      new GameButton(id: 9),
    ];
    return gameButtons;
  }

  void playGame(GameButton gb) {
    setState(() {
      if (activePlayer == 1) {
        gb.text = "X";
        gb.bg = Colors.red;
        activePlayer = 2;
        player1.add(gb.id);
      } else {
        gb.text = "0";
        gb.bg = Colors.black;
        activePlayer = 1;
        player2.add(gb.id);
      }
      gb.enabled = false;
      int winner = checkWinner();
      if (winner == -1) {
        if (buttonsList.every((p) => p.text != "")) {
  _updateScore(25); // Draw = 25 points
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomDialog(
          "Game Tied",
          "It’s a draw! You won +25 points.\nWould you like to play again or exit?",
          resetGame));
}
else {
          activePlayer == 2 ? autoPlay() : null;
        }
      }
    });
  }

  void autoPlay() {
    // Check if AI can win
    var move = _findWinningMove(player2);
    if (move != -1) {
      int i = buttonsList.indexWhere((p) => p.id == move);
      playGame(buttonsList[i]);
      return;
    }

    // Check if player is about to win and block
    move = _findWinningMove(player1);
    if (move != -1) {
      int i = buttonsList.indexWhere((p) => p.id == move);
      playGame(buttonsList[i]);
      return;
    }

    // Take center if available
    if (!player1.contains(5) && !player2.contains(5)) {
      int i = buttonsList.indexWhere((p) => p.id == 5);
      playGame(buttonsList[i]);
      return;
    }

    // Take corners if available (more strategic)
    var corners = [1, 3, 7, 9];
    var availableCorners = corners.where((c) => 
      !player1.contains(c) && !player2.contains(c)).toList();
      
    if (availableCorners.isNotEmpty) {
      var r = Random();
      var cornerIndex = r.nextInt(availableCorners.length);
      int i = buttonsList.indexWhere((p) => p.id == availableCorners[cornerIndex]);
      playGame(buttonsList[i]);
      return;
    }

    // Otherwise pick a random available cell
    var emptyCells = <int>[];
    var list = List.generate(9, (i) => i + 1);
    for (var cellID in list) {
      if (!(player1.contains(cellID) || player2.contains(cellID))) {
        emptyCells.add(cellID);
      }
    }

    if (emptyCells.isNotEmpty) {
      var r = Random();
      var randIndex = r.nextInt(emptyCells.length);
      var cellID = emptyCells[randIndex];
      int i = buttonsList.indexWhere((p) => p.id == cellID);
      playGame(buttonsList[i]);
    }
  }

  // Helper method to find winning move for a player
  int _findWinningMove(List<int> playerPositions) {
    // All possible winning combinations
    var winPatterns = [
      [1, 2, 3], [4, 5, 6], [7, 8, 9], // rows
      [1, 4, 7], [2, 5, 8], [3, 6, 9], // columns
      [1, 5, 9], [3, 5, 7]             // diagonals
    ];

    // Check each winning pattern
    for (var pattern in winPatterns) {
      // Count how many positions in this pattern the player already has
      var count = 0;
      var emptyPosition = -1;
      
      for (var pos in pattern) {
        if (playerPositions.contains(pos)) {
          count++;
        } else if (!player1.contains(pos) && !player2.contains(pos)) {
          // This position is empty
          emptyPosition = pos;
        }
      }
      
      // If player has 2 positions in a winning pattern and third is empty,
      // taking that position either wins (for AI) or blocks (for player)
      if (count == 2 && emptyPosition != -1) {
        return emptyPosition;
      }
    }
    
    return -1;
  }

  int checkWinner() {
    var winner = -1;
    if (player1.contains(1) && player1.contains(2) && player1.contains(3)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(2) && player2.contains(3)) {
      winner = 2;
    }

    // row 2
    if (player1.contains(4) && player1.contains(5) && player1.contains(6)) {
      winner = 1;
    }
    if (player2.contains(4) && player2.contains(5) && player2.contains(6)) {
      winner = 2;
    }

    // row 3
    if (player1.contains(7) && player1.contains(8) && player1.contains(9)) {
      winner = 1;
    }
    if (player2.contains(7) && player2.contains(8) && player2.contains(9)) {
      winner = 2;
    }

    // col 1
    if (player1.contains(1) && player1.contains(4) && player1.contains(7)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(4) && player2.contains(7)) {
      winner = 2;
    }

    // col 2
    if (player1.contains(2) && player1.contains(5) && player1.contains(8)) {
      winner = 1;
    }
    if (player2.contains(2) && player2.contains(5) && player2.contains(8)) {
      winner = 2;
    }

    // col 3
    if (player1.contains(3) && player1.contains(6) && player1.contains(9)) {
      winner = 1;
    }
    if (player2.contains(3) && player2.contains(6) && player2.contains(9)) {
      winner = 2;
    }

    //diagonal
    if (player1.contains(1) && player1.contains(5) && player1.contains(9)) {
      winner = 1;
    }
    if (player2.contains(1) && player2.contains(5) && player2.contains(9)) {
      winner = 2;
    }

    if (player1.contains(3) && player1.contains(5) && player1.contains(7)) {
      winner = 1;
    }
    if (player2.contains(3) && player2.contains(5) && player2.contains(7)) {
      winner = 2;
    }

   if (winner != -1) {
  if (winner == 1) {
    _updateScore(50); // Player 1 wins
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CustomDialog(
            "Player 1 Won",
            "You won +50 points!\nWould you like to play again or go back?",
            resetGame));
  } else {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CustomDialog(
            "Player 2 Won",
            "Would you like to play again or go back?",
            resetGame));
  }
}

    return winner;
  }

  void resetGame() {
    // Make sure to close any open dialogs first
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    
    // Then reset the game state
    setState(() {
      buttonsList = doInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Tic Tac Toe"),
        ),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Expanded(
              child: new GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 9.0,
                    mainAxisSpacing: 9.0),
                itemCount: buttonsList.length,
                itemBuilder: (context, i) => new SizedBox(
                      width: 100.0,
                      height: 100.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonsList[i].bg,
                          padding: const EdgeInsets.all(8.0),
                        ),
                        onPressed: buttonsList[i].enabled
                            ? () => playGame(buttonsList[i])
                            : null,
                        child: new Text(
                          buttonsList[i].text,
                          style: new TextStyle(
                              color: Colors.white, fontSize: 20.0),
                        ),
                      ),
                    ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(20.0),
              ),
              child: new Text(
                "Reset",
                style: new TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              onPressed: resetGame,
            )
          ],
        ));
  }

  Future<void> _updateScore(int points) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    // Get the current score
    final doc = await userDocRef.get();
    final currentScore = doc.data()?['score'] ?? 0;
    
    // Update total score
    await userDocRef.update({'score': currentScore + points});
    
    // Add score history entry
    await userDocRef.collection('scoreHistory').add({
      'score': points,
      'source': 'TicTacToe',
      'timestamp': FieldValue.serverTimestamp(),
      'details': points == 50 ? 'Game Win' : points == 25 ? 'Game Draw' : 'Game Loss'
    });
  }
}

}
