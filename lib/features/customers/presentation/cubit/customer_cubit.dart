import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/customers/data/models/customer_model.dart';
import 'package:odoo_flutter_task/features/customers/data/repositories/customer_repository.dart';
import 'package:odoo_flutter_task/features/customers/presentation/cubit/customer_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomerRepository customerRepository;

  List<CustomerModel> allCustomers = [];
  late final StreamSubscription<List<ConnectivityResult>>
  connectivitySubscription;
  bool wasOffline = false;

  CustomersCubit(this.customerRepository) : super(CustomersInitial()) {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      connection,
    ) {
      if (connection.contains(ConnectivityResult.none)) {
        wasOffline = true;
      } else if (wasOffline) {
        wasOffline = false;
        getCustomers();
      }
    });
  }

  @override
  Future<void> close() async {
    await connectivitySubscription.cancel();
    return super.close();
  }

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

  Future<PhoneUpdateResult?> updatePhone({
    required int customerId,
    required String phone,
  }) async {
    try {
      final result = await customerRepository.updatePhone(
        customerId: customerId,
        phone: phone,
      );

      if (result == PhoneUpdateResult.queued) {
        wasOffline = true;
      }

      await getCustomers();

      return result;
    } catch (e) {
      return null;
    }
  }
}
