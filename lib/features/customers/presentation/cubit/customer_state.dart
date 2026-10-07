import 'package:odoo_flutter_task/features/customers/data/models/customer_model.dart';

abstract class CustomersState {}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersSuccess extends CustomersState {
  final List<CustomerModel> customers;

  CustomersSuccess(this.customers);
}

class CustomersFailure extends CustomersState {
  final String message;

  CustomersFailure(this.message);
}
