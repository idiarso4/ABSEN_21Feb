class PKLLocation {
  final int id;
  final String name;
  final String address;
  final String? description;
  final double latitude;
  final double longitude;
  final bool isActive;

  PKLLocation({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory PKLLocation.fromJson(Map<String, dynamic> json) {
    return PKLLocation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }
} 