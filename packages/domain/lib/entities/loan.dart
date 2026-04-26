class Loan {
  final String id;
  final String name;
  final String source;
  final double originalAmount;
  final double monthlyPayment;
  final int originalTermMonths;
  final DateTime startDate;
  final String? note;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Loan({
    required this.id,
    required this.name,
    required this.source,
    required this.originalAmount,
    required this.monthlyPayment,
    this.originalTermMonths = 0,
    required this.startDate,
    this.note,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Loan copyWith({
    String? id,
    String? name,
    String? source,
    double? originalAmount,
    double? monthlyPayment,
    int? originalTermMonths,
    DateTime? startDate,
    String? note,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      originalAmount: originalAmount ?? this.originalAmount,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      originalTermMonths: originalTermMonths ?? this.originalTermMonths,
      startDate: startDate ?? this.startDate,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
