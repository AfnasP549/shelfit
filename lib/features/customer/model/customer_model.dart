class CustomerModel {
  String id;
  String name;
  String address;
  String mobileNumber;

  CustomerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.mobileNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'mobileNumber': mobileNumber,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
    );
  }
}
