class SalesOrderLineModel {
  final int id;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  SalesOrderLineModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SalesOrderLineModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderLineModel(
      id: json['id'],
      productName: _parseString(json['name']),
      quantity: _parseDouble(json['product_uom_qty']),
      unitPrice: _parseDouble(json['price_unit']),
      subtotal: _parseDouble(json['price_subtotal']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null || value == false) return '';
    return value.toString();
  }

  static double _parseDouble(dynamic value) {
    if (value == null || value == false) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
