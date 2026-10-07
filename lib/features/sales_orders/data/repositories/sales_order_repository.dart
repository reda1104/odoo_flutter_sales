import 'package:odoo_flutter_task/core/networks/odoo_service.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/models/sales_order_line_model.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/models/sales_order_model.dart';

class SalesOrderRepository {
  final OdooService odooService;

  SalesOrderRepository(this.odooService);

  Future<List<SalesOrderModel>> getSalesOrders() async {
    final result = await odooService.callKw(
      model: 'sale.order',
      method: 'search_read',
      args: [],
      kwargs: {
        'domain': [],
        'fields': [
          'id',
          'name',
          'partner_id',
          'date_order',
          'state',
          'amount_total',
          'order_line',
        ],
      },
    );
    return (result as List)
        .map(
          (salesOrder) =>
              SalesOrderModel.fromJson(Map<String, dynamic>.from(salesOrder)),
        )
        .toList();
  }

  Future<List<SalesOrderLineModel>> getSalesOrderLines(
    List<int> orderLineIds,
  ) async {
    if (orderLineIds.isEmpty) {
      return [];
    }

    final result = await odooService.callKw(
      model: 'sale.order.line',
      method: 'search_read',
      args: [],
      kwargs: {
        'domain': [
          ['id', 'in', orderLineIds],
        ],
        'fields': [
          'id',
          'name',
          'product_id',
          'product_uom_qty',
          'price_unit',
          'price_subtotal',
        ],
      },
    );

    return (result as List)
        .map(
          (line) =>
              SalesOrderLineModel.fromJson(Map<String, dynamic>.from(line)),
        )
        .toList();
  }

  Future<void> confirmSalesOrder(int orderId) async {
    await odooService.callKw(
      model: 'sale.order',
      method: 'action_confirm',
      args: [
        [orderId],
      ],
    );
  }
}
