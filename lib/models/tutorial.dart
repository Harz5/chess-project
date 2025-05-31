class Tutorial {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final List<TutorialStep> steps;
  final bool isCompleted;

  Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.steps,
    this.isCompleted = false,
  });

  Tutorial copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    List<TutorialStep>? steps,
    bool? isCompleted,
  }) {
    return Tutorial(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      steps: steps ?? this.steps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String boardFen;
  final List<String>? validMoves;
  final String? expectedMove;
  final bool isCompleted;

  TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.boardFen,
    this.validMoves,
    this.expectedMove,
    this.isCompleted = false,
  });

  TutorialStep copyWith({
    String? id,
    String? title,
    String? description,
    String? boardFen,
    List<String>? validMoves,
    String? expectedMove,
    bool? isCompleted,
  }) {
    return TutorialStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      boardFen: boardFen ?? this.boardFen,
      validMoves: validMoves ?? this.validMoves,
      expectedMove: expectedMove ?? this.expectedMove,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
