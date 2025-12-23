class Region {
  final String regionId;
  final String country;
  final String state;
  final String city;
  final String? postalCode;
  final String region;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Region({
    required this.regionId,
    required this.country,
    required this.state,
    required this.city,
    this.postalCode,
    required this.region,
    this.createdAt,
    this.updatedAt,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      regionId: json['region_id'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postal_code'],
      region: json['region'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region_id': regionId,
      'country': country,
      'state': state,
      'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      'region': region,
    };
  }

  Region copyWith({
    String? regionId,
    String? country,
    String? state,
    String? city,
    String? postalCode,
    String? region,
  }) {
    return Region(
      regionId: regionId ?? this.regionId,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      region: region ?? this.region,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get fullAddress => '$city, $state, $country';
}
