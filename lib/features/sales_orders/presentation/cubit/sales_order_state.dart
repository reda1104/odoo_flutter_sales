import 'package:odoo_flutter_task/features/sales_orders/data/models/sales_order_model.dart';

abstract class SalesOrderState {}

class SalesOrderInitial extends SalesOrderState {}

class SalesOrderLoading extends SalesOrderState {}

class SalesOrderSuccess extends SalesOrderState {
  final List<SalesOrderModel> salesOrders;

  SalesOrderSuccess(this.salesOrders);
}

class SalesOrderFailure extends SalesOrderState {
  final String message;

  SalesOrderFailure(this.message);
}
