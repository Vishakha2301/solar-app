class CapacityBasedComponent {
  String capacity;
  String basePrice;
  String quantity;
  String gstRate;
  String unit;

  CapacityBasedComponent({
    required this.capacity,
    required this.basePrice,
    required this.quantity,
    required this.gstRate,
    required this.unit,
  });
}

class PercentageBasedComponent {
  String percentage;

  PercentageBasedComponent({
    required this.percentage,
  });
}

class FixedAmountComponent {
  String amount;

  FixedAmountComponent({
    required this.amount,
  });
}
