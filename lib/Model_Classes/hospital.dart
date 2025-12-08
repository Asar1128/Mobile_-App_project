class Hospital {
  final String hospitalId;
  final String hospitalName;
  final String address;
  final String city;
  final String phoneNumber;
  final String email;
  final String licenseNumber;

  Hospital({
    required this.hospitalId,
    required this.hospitalName,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.email,
    required this.licenseNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'address': address,
      'city': city,
      'phoneNumber': phoneNumber,
      'email': email,
      'licenseNumber': licenseNumber,
    };
  }

  factory Hospital.fromJson(Map<dynamic, dynamic> json) {
    return Hospital(
      hospitalId: json['hospitalId'],
      hospitalName: json['hospitalName'],
      address: json['address'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      licenseNumber: json['licenseNumber'],
    );
  }
}