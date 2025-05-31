/// Repräsentiert eine Position auf dem Schachbrett.
/// 
/// Die Position wird durch Zeile und Spalte definiert, wobei
/// beide Werte zwischen 0 und 7 liegen (0-basierte Indizierung).
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  /// Erstellt eine Position aus algebraischer Notation (z.B. "a1", "e4").
  factory Position.fromAlgebraic(String algebraic) {
    if (algebraic.length != 2) {
      throw ArgumentError('Algebraische Notation muss genau 2 Zeichen lang sein');
    }
    
    final col = algebraic.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final row = 8 - int.parse(algebraic[1]);
    
    if (col < 0 || col > 7 || row < 0 || row > 7) {
      throw ArgumentError('Ungültige algebraische Notation: $algebraic');
    }
    
    return Position(row, col);
  }

  /// Konvertiert die Position in algebraische Notation (z.B. "a1", "e4").
  String toAlgebraic() {
    final colChar = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rowNum = 8 - row;
    return '$colChar$rowNum';
  }

  /// Überprüft, ob die Position innerhalb des Schachbretts liegt.
  bool isValid() {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  /// Erstellt eine neue Position, die um die angegebenen Werte verschoben ist.
  Position offset(int rowOffset, int colOffset) {
    return Position(row + rowOffset, col + colOffset);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'Position(${toAlgebraic()})';
}
