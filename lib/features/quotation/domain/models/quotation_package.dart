import '../../../material/domain/models/material_item.dart';

class QuotationPackageMaterial {
  final String id;
  final MaterialItem material;
  final String componentKey;
  final bool isRecommended;

  const QuotationPackageMaterial({
    required this.id,
    required this.material,
    required this.componentKey,
    required this.isRecommended,
  });

  factory QuotationPackageMaterial.fromJson(Map<String, dynamic> json) =>
      QuotationPackageMaterial(
        id: json['id'] as String,
        material: MaterialItem.fromJson(
            json['material'] as Map<String, dynamic>),
        componentKey: json['componentKey'] as String,
        isRecommended: json['isRecommended'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'materialId': material.id,
        'componentKey': componentKey,
        'isRecommended': isRecommended,
      };
}

class QuotationPackage {
  final String id;
  final String packageName;
  final bool isRecommended;
  final List<QuotationPackageMaterial> materials;

  const QuotationPackage({
    required this.id,
    required this.packageName,
    required this.isRecommended,
    required this.materials,
  });

  factory QuotationPackage.fromJson(Map<String, dynamic> json) =>
      QuotationPackage(
        id: json['id'] as String,
        packageName: json['packageName'] as String,
        isRecommended: json['isRecommended'] as bool? ?? false,
        materials: (json['materials'] as List<dynamic>? ?? [])
            .map((e) => QuotationPackageMaterial.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'isRecommended': isRecommended,
        'materials': materials.map((m) => m.toJson()).toList(),
      };
}