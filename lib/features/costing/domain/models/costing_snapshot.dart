import 'component_cost.dart';
import 'component_input_snapshot.dart';

class CostingSnapshot {
  final double systemSubTotal;
  final double subsidyProcessingFee;
  final double contingency;
  final double cp1;
  final double cp2;
  final double amc;
  final double grandTotal;
  final double projectCostAfterGst;
  final double perWpAfterGst;
  final Map<String, ComponentCost> components;
  final Map<String, ComponentInputSnapshot> componentInputs;

  const CostingSnapshot({
    required this.systemSubTotal,
    required this.subsidyProcessingFee,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.grandTotal,
    required this.projectCostAfterGst,
    required this.perWpAfterGst,
    required this.components,
    required this.componentInputs,
  });

  Map<String, dynamic> toJson() => {
        'systemSubTotal': systemSubTotal,
        'subsidyProcessingFee': subsidyProcessingFee,
        'contingency': contingency,
        'cp1': cp1,
        'cp2': cp2,
        'amc': amc,
        'grandTotal': grandTotal,
        'projectCostAfterGst': projectCostAfterGst,
        'perWpAfterGst': perWpAfterGst,
        'components': components.map((k, v) => MapEntry(k, v.toJson())),
        'componentInputs':
            componentInputs.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory CostingSnapshot.fromJson(Map<String, dynamic> json) =>
    CostingSnapshot(
      systemSubTotal: (json['systemSubTotal'] as num?)?.toDouble() ?? 0,
      subsidyProcessingFee: (json['subsidyProcessingFee'] as num?)?.toDouble() ?? 0,
      contingency: (json['contingency'] as num?)?.toDouble() ?? 0,
      cp1: (json['cp1'] as num?)?.toDouble() ?? 0,
      cp2: (json['cp2'] as num?)?.toDouble() ?? 0,
      amc: (json['amc'] as num?)?.toDouble() ?? 0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0,
      projectCostAfterGst: (json['projectCostAfterGst'] as num?)?.toDouble() ?? 0,
      perWpAfterGst: (json['perWpAfterGst'] as num?)?.toDouble() ?? 0,
      components: (json['components'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, ComponentCost.fromJson(v as Map<String, dynamic>)),
          ) ?? {},
      componentInputs: (json['componentInputs'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, ComponentInputSnapshot.fromJson(v as Map<String, dynamic>)),
          ) ?? {},
    );
}