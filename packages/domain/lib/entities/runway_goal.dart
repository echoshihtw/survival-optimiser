class RunwayGoal {
  final String id;
  final String name;
  final int targetMonths;
  final DateTime? targetDate;

  const RunwayGoal({
    required this.id,
    required this.name,
    required this.targetMonths,
    this.targetDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetMonths': targetMonths,
    'targetDate': targetDate?.toIso8601String(),
  };

  factory RunwayGoal.fromJson(Map<String, dynamic> json) => RunwayGoal(
    id: json['id'] as String,
    name: json['name'] as String,
    targetMonths: json['targetMonths'] as int,
    targetDate: json['targetDate'] == null
        ? null
        : DateTime.parse(json['targetDate'] as String),
  );
}
