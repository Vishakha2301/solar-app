class MaterialCategoryInfo {
  final String value;
  final String label;

  const MaterialCategoryInfo({required this.value, required this.label});

  factory MaterialCategoryInfo.fromJson(Map<String, dynamic> json) =>
      MaterialCategoryInfo(
        value: json['value'] as String,
        label: json['label'] as String,
      );
}

class MaterialItem {
  final String id;
  final MaterialCategoryInfo category;
  final String? componentKey;
  final String brandName;
  final String modelName;
  final String? specification;
  final String? unit;
  final String? warranty;
  final String? hsnCode;
  final bool active;
  final DateTime createdAt;
  final String createdBy;

  const MaterialItem({
    required this.id,
    required this.category,
    this.componentKey,
    required this.brandName,
    required this.modelName,
    this.specification,
    this.unit,
    this.warranty,
    this.hsnCode,
    required this.active,
    required this.createdAt,
    required this.createdBy,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) => MaterialItem(
        id: json['id'] as String,
        category: MaterialCategoryInfo.fromJson(
            json['category'] as Map<String, dynamic>),
        componentKey: json['componentKey'] as String?,
        brandName: json['brandName'] as String,
        modelName: json['modelName'] as String,
        specification: json['specification'] as String?,
        unit: json['unit'] as String?,
        warranty: json['warranty'] as String?,
        hsnCode: json['hsnCode'] as String?,
        active: json['active'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        createdBy: json['createdBy'] as String,
      );

  Map<String, dynamic> toJson() => {
        'category': category.value,
        'componentKey': componentKey,
        'brandName': brandName,
        'modelName': modelName,
        'specification': specification,
        'unit': unit,
        'warranty': warranty,
        'hsnCode': hsnCode,
      };
}