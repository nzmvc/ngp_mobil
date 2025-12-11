class Payment {
  final int id;
  final String studentName;
  final double amount;
  final String date;
  final String description;

  Payment({
    required this.id,
    required this.studentName,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      studentName: json['student_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  String get formattedAmount => '${amount.toStringAsFixed(2)} ₺';
}
