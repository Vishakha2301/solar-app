class QuotationCosting {
  final String id;
  final String costingId;
  final String? roofLabel;

  const QuotationCosting({
    required this.id,
    required this.costingId,
    this.roofLabel,
  });

  factory QuotationCosting.fromJson(Map<String, dynamic> json) =>
      QuotationCosting(
        id: json['id'] as String,
        costingId: json['costingId'] as String,
        roofLabel: json['roofLabel'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'costingId': costingId,
        'roofLabel': roofLabel,
      };
}