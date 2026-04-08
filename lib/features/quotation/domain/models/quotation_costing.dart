class QuotationCosting {
  final String id;
  final String costingId;
  final String? roofLabel;
  final double subsidyAmount;

  const QuotationCosting({
    required this.id,
    required this.costingId,
    this.roofLabel,
    this.subsidyAmount = 0,
  });

  factory QuotationCosting.fromJson(Map<String, dynamic> json) =>
      QuotationCosting(
        id: json['id'] as String,
        costingId: json['costingId'] as String,
        roofLabel: json['roofLabel'] as String?,
        subsidyAmount:
            (json['subsidyAmount'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'costingId': costingId,
        'roofLabel': roofLabel,
        'subsidyAmount': subsidyAmount,
      };
}