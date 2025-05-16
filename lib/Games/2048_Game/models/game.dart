import 'dart:math' show Random;
import 'boardcell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final int row;
  final int column;
  int score = 0;
  bool _isGameOver = false;

  Game(this.row, this.column);

  late List<List<BoardCell>> _boardCells;
  void init() {
    _boardCells = <List<BoardCell>>[];
    for (int r = 0; r < row; ++r) {
      _boardCells.add(<BoardCell>[]);
      for (int c = 0; c < column; ++c) {
        _boardCells[r].add(BoardCell(
          row: r,
          column: c,
          number: 0,
          isNew: false,
        ));
      }
    }
    score = 0;
    _isGameOver = false;
    resetMergeStatus();
    randomEmptyCell(2);
  }

  BoardCell get(int r, int c) {
    return _boardCells[r][c];
  }

  void moveLeft() {
    if (!canMoveLeft()) {
      return;
    }
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        mergeLeft(r, c);
      }
    }
    randomEmptyCell(1);
    resetMergeStatus();
  }

  void moveRight() {
    if (!canMoveRight()) {
      return;
    }
    for (int r = 0; r < row; ++r) {
      for (int c = column - 2; c >= 0; --c) {
        mergeRight(r, c);
      }
    }
    randomEmptyCell(1);
    resetMergeStatus();
  }

  void moveUp() {
    if (!canMoveUp()) {
      return;
    }
    for (int r = 0; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        mergeUp(r, c);
      }
    }
    randomEmptyCell(1);
    resetMergeStatus();
  }

  void moveDown() {
    if (!canMoveDown()) {
      return;
    }
    for (int r = row - 2; r >= 0; --r) {
      for (int c = 0; c < column; ++c) {
        mergeDown(r, c);
      }
    }
    randomEmptyCell(1);
    resetMergeStatus();
  }

  bool canMoveLeft() {
    for (int r = 0; r < row; ++r) {
      for (int c = 1; c < column; ++c) {
        if (canMerge(_boardCells[r][c], _boardCells[r][c - 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveRight() {
    for (int r = 0; r < row; ++r) {
      for (int c = column - 2; c >= 0; --c) {
        if (canMerge(_boardCells[r][c], _boardCells[r][c + 1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveUp() {
    for (int r = 1; r < row; ++r) {
      for (int c = 0; c < column; ++c) {
        if (canMerge(_boardCells[r][c], _boardCells[r - 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  bool canMoveDown() {
    for (int r = row - 2; r >= 0; --r) {
      for (int c = 0; c < column; ++c) {
        if (canMerge(_boardCells[r][c], _boardCells[r + 1][c])) {
          return true;
        }
      }
    }
    return false;
  }

  void mergeLeft(int r, int c) {
    while (c > 0) {
      merge(_boardCells[r][c], _boardCells[r][c - 1]);
      c--;
    }
  }

  void mergeRight(int r, int c) {
    while (c < column - 1) {
      merge(_boardCells[r][c], _boardCells[r][c + 1]);
      c++;
    }
  }

  void mergeUp(int r, int c) {
    while (r > 0) {
      merge(_boardCells[r][c], _boardCells[r - 1][c]);
      r--;
    }
  }

  void mergeDown(int r, int c) {
    while (r < row - 1) {
      merge(_boardCells[r][c], _boardCells[r + 1][c]);
      r++;
    }
  }

  bool canMerge(BoardCell a, BoardCell b) {
    return !b.isMerged &&
        ((b.isEmpty() && !a.isEmpty()) || (!a.isEmpty() && a == b));
  }

  void merge(BoardCell a, BoardCell b) {
    if (!canMerge(a, b)) {
      if (!a.isEmpty() && !b.isMerged) {
        b.isMerged = true;
      }
      return;
    }

    if (b.isEmpty()) {
      b.number = a.number;
      a.number = 0;
    } else if (a == b) {
      b.number = b.number * 2;
      a.number = 0;
      
      // Modified scoring system - only add the value of the new tile
      // This makes it harder to accumulate high scores quickly
      score += b.number ~/ 4;
      
      b.isMerged = true;
    } else {
      b.isMerged = true;
    }
  }

  bool isGameOver() {
    if (!canMoveLeft() && !canMoveRight() && !canMoveUp() && !canMoveDown()) {
      if (!_isGameOver) {
        _isGameOver = true;
        // Only update Firebase score once when the game is truly over
        updateScoreToFirebase();
      }
      return true;
    }
    return false;
  }

  void randomEmptyCell(int cnt) {
    List<BoardCell> emptyCells = <BoardCell>[];
    _boardCells.forEach((cells) {
      emptyCells.addAll(cells.where((cell) {
        return cell.isEmpty();
      }));
    });
    if (emptyCells.isEmpty) {
      return;
    }
    Random r = Random();
    for (int i = 0; i < cnt && emptyCells.isNotEmpty; i++) {
      int index = r.nextInt(emptyCells.length);
      emptyCells[index].number = randomCellNum();
      emptyCells[index].isNew = true;
      emptyCells.removeAt(index);
    }
  }

  int randomCellNum() {
    final Random r = Random();
    return r.nextInt(15) == 0 ? 4 : 2;
  }

  void resetMergeStatus() {
    _boardCells.forEach((cells) {
      cells.forEach((cell) {
        cell.isMerged = false;
        cell.isNew = false;
      });
    });
  }
  
  // Update score to Firebase - only called once at game over
  Future<void> updateScoreToFirebase() async {
    try {
      final user = AuthService().currentUser;
      if (user != null && score > 0) {
        final docRef = AuthService().firestore.collection('users').doc(user.uid);
        final snapshot = await docRef.get();
        
        // Get existing score and add new score from this game
        final currentScore = snapshot.data()?['score'] ?? 0;
        final newScore = currentScore + score;
        
        // Update Firestore with new score
        await docRef.update({'score': newScore});
      }
    } catch (e) {
      print('Error updating score to Firebase: $e');
    }
  }
}