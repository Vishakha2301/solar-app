class CustomerSite {
  final String id;
  final String siteLabel;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isDefault;
  final DateTime createdAt;

  const CustomerSite({
    required this.id,
    required this.siteLabel,
    this.address,
    this.city,
    this.state,
    this.pincode,
    required this.isDefault,
    required this.createdAt,
  });

  factory CustomerSite.fromJson(Map<String, dynamic> json) => CustomerSite(
        id: json['id'] as String,
        siteLabel: json['siteLabel'] as String,
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        pincode: json['pincode'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'siteLabel': siteLabel,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'isDefault': isDefault,
      };
}