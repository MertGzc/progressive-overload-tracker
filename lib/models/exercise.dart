class LogEntry {
  final String id;
  final String date;
  final String weight;
  final List<String> sets;
  final String day;

  LogEntry({
    required this.id,
    required this.date,
    required this.weight,
    required this.sets,
    required this.day,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'date': date, 'weight': weight, 'sets': sets, 'day': day};
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      weight: json['weight'] ?? '',
      sets: List<String>.from(json['sets'] ?? []),
      day: json['day'] ?? '',
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String targetReps;
  final String? lastLog;
  final List<LogEntry>? history;
  final List<String>? assignedDays; // Hareketin atandığı bütün günlen
  Exercise({
    required this.id,
    required this.name,
    required this.targetReps,
    this.lastLog,
    this.history,
    this.assignedDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetReps': targetReps,
      'lastLog': lastLog,
      'history': history?.map((h) => h.toJson()).toList(),
      'assignedDays': assignedDays,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      targetReps: json['targetReps'] ?? '',
      lastLog: json['lastLog'],
      history:
          json['history'] != null
              ? (json['history'] as List)
                  .map((h) => LogEntry.fromJson(h))
                  .toList()
              : null,
      assignedDays:
          json['assignedDays'] != null
              ? List<String>.from(json['assignedDays'])
              : null,
    );
  }
}
