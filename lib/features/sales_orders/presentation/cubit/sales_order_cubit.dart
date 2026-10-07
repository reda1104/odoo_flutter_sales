import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/models/sales_order_line_model.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/repositories/sales_order_repository.dart';
import 'package:odoo_flutter_task/features/sales_orders/presentation/cubit/sales_order_state.dart';

class SalesOrderCubit extends Cubit<SalesOrderState> {
  SalesOrderCubit(this.salesOrderRepository) : super(SalesOrderInitial());
  final SalesOrderRepository salesOrderRepository;

  Future<void> getSalesOrders() async {
    emit(SalesOrderLoading());

    try {
      final salesOrders = await salesOrderRepository.getSalesOrders();

      emit(SalesOrderSuccess(salesOrders));
    } catch (e) {
      emit(SalesOrderFailure(e.toString()));
    }
  }

  Future<List<SalesOrderLineModel>> getSalesOrderLines(
    List<int> orderLineIds,
  ) async {
    return await salesOrderRepository.getSalesOrderLines(orderLineIds);
  }

  Future<bool> confirmSalesOrder(int orderId) async {
    try {
      await salesOrderRepository.confirmSalesOrder(orderId);
      await getSalesOrders();
      return true;
    } catch (e) {
      return false;
    }
  }
}
