import 'exercise.dart';

class TrainingProgram {
  final String id;
  final String trainerId;
  final String userId;
  final String programName;
  final Map<String, List<Exercise>> exercises; // Günler ve egzersizler
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  TrainingProgram({
    required this.id,
    required this.trainerId,
    required this.userId,
    required this.programName,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    final exercisesMap = <String, List<Exercise>>{};
    if (json['exercises'] is Map) {
      (json['exercises'] as Map).forEach((day, exList) {
        if (exList is List) {
          exercisesMap[day as String] =
              exList
                  .map((ex) => Exercise.fromJson(ex as Map<String, dynamic>))
                  .toList();
        }
      });
    }

    return TrainingProgram(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      userId: json['userId'] as String,
      programName: json['programName'] as String? ?? 'Antrenman Programı',
      exercises: exercisesMap,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final exercisesMap = <String, dynamic>{};
    exercises.forEach((day, exList) {
      exercisesMap[day] = exList.map((ex) => ex.toJson()).toList();
    });

    return {
      'id': id,
      'trainerId': trainerId,
      'userId': userId,
      'programName': programName,
      'exercises': exercisesMap,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  TrainingProgram copyWith({
    String? id,
    String? trainerId,
    String? userId,
    String? programName,
    Map<String, List<Exercise>>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TrainingProgram(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      userId: userId ?? this.userId,
      programName: programName ?? this.programName,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
