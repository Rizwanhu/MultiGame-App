class BoardCell {
  final int row;
  final int column;
  int number;
  bool isNew;
  bool isMerged = false;

  BoardCell({
    required this.row,
    required this.column,
    required this.number,
    required this.isNew,
  });

  bool isEmpty() {
    return number == 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardCell) return false;
    return number != 0 && number == other.number;
  }

  @override
  int get hashCode => number.hashCode;
}