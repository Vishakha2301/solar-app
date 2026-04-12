import 'package:flutter/material.dart' show Color, Colors;
import '../../../customer/domain/models/customer.dart';
import '../../../customer/domain/models/customer_site.dart';
import 'quotation_costing.dart';
import 'quotation_instalment.dart';
import 'quotation_package.dart';

enum QuotationStatus { DRAFT, SUBMITTED, APPROVED, REJECTED, REVISED, CANCELLED }

class Quotation {
  final String id;
  final String quotationNumber;
  final Customer customer;
  final CustomerSite? customerSite;
  final QuotationStatus status;
  final String? systemType;
  final int validityDays;
  final double discount;
  final String? scopeOfWork;
  final String? paymentTerms;
  final String? termsAndConditions;
  final String? notes;
  final bool financingAvailable;
  final double? financingRate;
  final String? rejectionReason;
  final String? approvalNotes;
  final String createdBy;
  final DateTime? submittedAt;
  final String? approvedRejectedBy;
  final DateTime? approvedRejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<QuotationCosting> costings;
  final List<QuotationInstalment> instalments;
  final List<QuotationPackage> packages;

  const Quotation({
    required this.id,
    required this.quotationNumber,
    required this.customer,
    this.customerSite,
    required this.status,
    this.systemType,
    required this.validityDays,
    required this.discount,
    this.scopeOfWork,
    this.paymentTerms,
    this.termsAndConditions,
    this.notes,
    required this.financingAvailable,
    this.financingRate,
    this.rejectionReason,
    this.approvalNotes,
    required this.createdBy,
    this.submittedAt,
    this.approvedRejectedBy,
    this.approvedRejectedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.costings,
    required this.instalments,
    required this.packages,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
        id: json['id'] as String,
        quotationNumber: json['quotationNumber'] as String,
        customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
        customerSite: json['customerSite'] != null
            ? CustomerSite.fromJson(json['customerSite'] as Map<String, dynamic>)
            : null,
        status: QuotationStatus.values.byName(json['status'] as String),
        systemType: json['systemType'] as String?,
        validityDays: json['validityDays'] as int? ?? 30,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        scopeOfWork: json['scopeOfWork'] as String?,
        paymentTerms: json['paymentTerms'] as String?,
        termsAndConditions: json['termsAndConditions'] as String?,
        notes: json['notes'] as String?,
        financingAvailable: json['financingAvailable'] as bool? ?? false,
        financingRate: (json['financingRate'] as num?)?.toDouble(),
        rejectionReason: json['rejectionReason'] as String?,
        approvalNotes: json['approvalNotes'] as String?,
        createdBy: json['createdBy'] as String,
        submittedAt: json['submittedAt'] != null
            ? DateTime.parse(json['submittedAt'] as String)
            : null,
        approvedRejectedBy: json['approvedRejectedBy'] as String?,
        approvedRejectedAt: json['approvedRejectedAt'] != null
            ? DateTime.parse(json['approvedRejectedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        costings: (json['costings'] as List<dynamic>? ?? [])
            .map((e) => QuotationCosting.fromJson(e as Map<String, dynamic>))
            .toList(),
        instalments: (json['instalments'] as List<dynamic>? ?? [])
            .map((e) => QuotationInstalment.fromJson(e as Map<String, dynamic>))
            .toList(),
        packages: (json['packages'] as List<dynamic>? ?? [])
            .map((e) => QuotationPackage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String get statusLabel => switch (status) {
        QuotationStatus.DRAFT => 'Draft',
        QuotationStatus.SUBMITTED => 'Submitted',
        QuotationStatus.APPROVED => 'Approved',
        QuotationStatus.REJECTED => 'Rejected',
        QuotationStatus.REVISED => 'Revised',
        QuotationStatus.CANCELLED => 'Cancelled',
      };

  Color get statusColor => switch (status) {
        QuotationStatus.DRAFT => const Color(0xFF9E9E9E),
        QuotationStatus.SUBMITTED => const Color(0xFF2196F3),
        QuotationStatus.APPROVED => const Color(0xFF4CAF50),
        QuotationStatus.REJECTED => const Color(0xFFF44336),
        QuotationStatus.REVISED => const Color(0xFFFF9800),
        QuotationStatus.CANCELLED => const Color(0xFF607D8B),
      };
}
