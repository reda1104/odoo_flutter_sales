class CustomerModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final String street;
  final String street2;
  final String zip;
  final String country;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.city,
    required this.street,
    required this.street2,
    required this.zip,
    required this.country,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: _parseString(json['name']),
      phone: _parseString(json['phone']),
      email: _parseString(json['email']),
      city: _parseString(json['city']),
      street: _parseString(json['street']),
      street2: _parseString(json['street2']),
      zip: _parseString(json['zip']),
      country: _parseCountry(json['country_id']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null || value == false) {
      return '';
    }

    return value.toString();
  }

  static String _parseCountry(dynamic value) {
    if (value == null || value == false) {
      return '';
    }

    if (value is List && value.length > 1) {
      return value[1].toString();
    }

    return '';
  }

  String get fullAddress {
    return [
      street,
      street2,
      city,
      zip,
      country,
    ].where((value) => value.isNotEmpty).join(', ');
  }
}
