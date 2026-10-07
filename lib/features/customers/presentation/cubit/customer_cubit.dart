import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/customers/data/models/customer_model.dart';
import 'package:odoo_flutter_task/features/customers/data/repositories/customer_repository.dart';
import 'package:odoo_flutter_task/features/customers/presentation/cubit/customer_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomerRepository customerRepository;

  List<CustomerModel> allCustomers = [];

  CustomersCubit(this.customerRepository) : super(CustomersInitial());

  Future<void> getCustomers() async {
    emit(CustomersLoading());

    try {
      final customers = await customerRepository.getCustomers();

      allCustomers = customers;

      emit(CustomersSuccess(customers));
    } catch (e) {
      emit(CustomersFailure(e.toString()));
    }
  }

  void searchCustomers(String query) {
    if (query.trim().isEmpty) {
      emit(CustomersSuccess(allCustomers));
      return;
    }

    final filteredCustomers = allCustomers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(CustomersSuccess(filteredCustomers));
  }

  Future<bool> updatePhone({
    required int customerId,
    required String phone,
  }) async {
    try {
      await customerRepository.updatePhone(
        customerId: customerId,
        phone: phone,
      );

      await getCustomers();

      return true;
    } catch (e) {
      return false;
    }
  }
}
