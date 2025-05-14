import 'package:flutter/material.dart';
import '../models/boardcell.dart';
import '../screens/game_screen.dart';
import '../widgets/cellbox.dart';
import '../constants.dart';

class AnimatedCellWidget extends AnimatedWidget {
  final BoardCell cell;
  final GameWidgetState state;
  
  AnimatedCellWidget({
    Key? key, 
    required this.cell, 
    required this.state, 
    required Animation<double> animation
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable as Animation<double>;
    double animationValue = animation.value;
    Size boardSize = state.boardSize();
    double width = (boardSize.width - (state.column + 1) * state.cellPadding) /
        state.column;
    if (cell.number == 0) {
      return Container();
    } else {
      return CellBox(
        left: (cell.column * width + state.cellPadding * (cell.column + 1)) +
            width / 2 * (1 - animationValue),
        top: cell.row * width +
            state.cellPadding * (cell.row + 1) +
            width / 2 * (1 - animationValue),
        size: width * animationValue,
        color: boxColor.containsKey(cell.number)
            ? boxColor[cell.number]!  // Add ! to handle nullable
            : boxColor[boxColor.keys.last]!,  // Add ! to handle nullable
        text: Text(
          cell.number.toString(),
          style: TextStyle(
            fontSize: 30.0 * animationValue,
            fontWeight: FontWeight.bold,
            color: (cell.number < 32 ? Colors.grey[600] : Colors.grey[50])!,  // Add ! to handle nullable
          ),
        ),
      );
    }
  }
}