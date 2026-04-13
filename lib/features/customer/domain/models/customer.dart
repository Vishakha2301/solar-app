// ignore_for_file: constant_identifier_names

import 'customer_site.dart';

enum CustomerType { INDIVIDUAL, COMPANY, SOCIETY }

class Customer {
  final String id;
  final CustomerType customerType;
  final String name;
  final String? companyName;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? gstNumber;
  final bool active;
  final DateTime createdAt;
  final String createdBy;
  final List<CustomerSite> sites;

  const Customer({
    required this.id,
    required this.customerType,
    required this.name,
    this.companyName,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.gstNumber,
    required this.active,
    required this.createdAt,
    required this.createdBy,
    required this.sites,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        customerType: CustomerType.values.byName(
            json['customerType'] as String),
        name: json['name'] as String,
        companyName: json['companyName'] as String?,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        pincode: json['pincode'] as String?,
        gstNumber: json['gstNumber'] as String?,
        active: json['active'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        createdBy: json['createdBy'] as String,
        sites: (json['sites'] as List<dynamic>? ?? [])
            .map((e) => CustomerSite.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'customerType': customerType.name,
        'name': name,
        'companyName': companyName,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'gstNumber': gstNumber,
        'sites': sites.map((s) => s.toJson()).toList(),
      };

  String get displayName => customerType == CustomerType.COMPANY
      ? (companyName ?? name)
      : name;
}
