import 'calculator_fields.dart';

class QuotationInput {
  String plantCapacity;

  CapacityBasedComponent solarPanel;
  CapacityBasedComponent invertor;
  CapacityBasedComponent mountingStructure;
  CapacityBasedComponent dcdb;
  CapacityBasedComponent acdb;
  CapacityBasedComponent acArmouredCable;
  CapacityBasedComponent acFlexibleCable;
  CapacityBasedComponent dcCable;
  CapacityBasedComponent acEarthingCable;
  CapacityBasedComponent earthingMaterial;
  CapacityBasedComponent la;
  CapacityBasedComponent installation;
  CapacityBasedComponent civilWork;
  CapacityBasedComponent electricalsPlumbing;
  CapacityBasedComponent transport;
  CapacityBasedComponent netMetersAndFees;
  CapacityBasedComponent netMeteringPayments;

  PercentageBasedComponent contingency;
  PercentageBasedComponent cp1;
  PercentageBasedComponent cp2;
  PercentageBasedComponent amc;

  FixedAmountComponent subsidyProcessingFee;

  bool isSubsidyProject;


  QuotationInput({
    required this.plantCapacity,
    required this.solarPanel,
    required this.invertor,
    required this.mountingStructure,
    required this.dcdb,
    required this.acdb,
    required this.acArmouredCable,
    required this.acFlexibleCable,
    required this.dcCable,
    required this.acEarthingCable,
    required this.earthingMaterial,
    required this.la,
    required this.installation,
    required this.civilWork,
    required this.electricalsPlumbing,
    required this.transport,
    required this.netMetersAndFees,
    required this.netMeteringPayments,
    required this.contingency,
    required this.cp1,
    required this.cp2,
    required this.amc,
    required this.subsidyProcessingFee,
    required this.isSubsidyProject,
  });
}
