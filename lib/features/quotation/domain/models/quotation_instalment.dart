class QuotationInstalment {
  final String id;
  final int instalmentNo;
  final String description;
  final double percentage;

  const QuotationInstalment({
    required this.id,
    required this.instalmentNo,
    required this.description,
    required this.percentage,
  });

  factory QuotationInstalment.fromJson(Map<String, dynamic> json) =>
      QuotationInstalment(
        id: json['id'] as String,
        instalmentNo: json['instalmentNo'] as int,
        description: json['description'] as String,
        percentage: (json['percentage'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'instalmentNo': instalmentNo,
        'description': description,
        'percentage': percentage,
      };
}