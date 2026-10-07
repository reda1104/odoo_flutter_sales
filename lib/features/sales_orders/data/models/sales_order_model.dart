class SalesOrderModel {
  final int id;
  final String orderNumber;
  final String customerName;
  final String orderDate;
  final String status;
  final double total;
  final List<int> orderLineIds;

  SalesOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.orderDate,
    required this.status,
    required this.total,
    required this.orderLineIds,
  });

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'],
      orderNumber: _parseString(json['name']),
      customerName: _parseMany2OneName(json['partner_id']),
      orderDate: _parseString(json['date_order']),
      status: _parseString(json['state']),
      total: _parseDouble(json['amount_total']),
      orderLineIds: _parseIds(json['order_line']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null || value == false) return '';
    return value.toString();
  }

  static String _parseMany2OneName(dynamic value) {
    if (value == null || value == false) return '';

    if (value is List && value.length > 1) {
      return value[1].toString();
    }

    return '';
  }

  static double _parseDouble(dynamic value) {
    if (value == null || value == false) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  static List<int> _parseIds(dynamic value) {
    if (value is! List) return [];

    return value.whereType<int>().toList();
  }
}
