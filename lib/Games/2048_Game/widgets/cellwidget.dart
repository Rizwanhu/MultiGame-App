import 'package:flutter/material.dart';
import '../models/boardcell.dart';
import '../screens/game_screen.dart';
import '../widgets/animatedcellwidget.dart';

class CellWidget extends StatefulWidget {
  final BoardCell cell;
  final GameWidgetState state;
  CellWidget({required this.cell, required this.state});

  _CellWidgetState createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
late Animation<double> animation;
  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(
        milliseconds: 200,
      ),
      vsync: this,
    );
    animation = new Tween(begin: 0.0, end: 1.0).animate(controller);
  }

  dispose() {
    controller.dispose();
    super.dispose();
    widget.cell.isNew = false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cell.isNew && !widget.cell.isEmpty()) {
      controller.reset();
      controller.forward();
      widget.cell.isNew = false;
    } else {
      controller.animateTo(1.0);
    }
    return AnimatedCellWidget(
      cell: widget.cell,
      state: widget.state,
      animation: animation,
    );
  }
}
