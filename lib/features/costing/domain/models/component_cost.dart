class ComponentCost {
  final String name;
  final double quantity;
  final double unitPrice;
  final double subTotal;

  ComponentCost({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'subTotal': subTotal,
      };

  factory ComponentCost.fromJson(Map<String, dynamic> json) => ComponentCost(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0,
      );
}