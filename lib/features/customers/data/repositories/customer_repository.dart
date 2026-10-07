import 'package:odoo_flutter_task/core/networks/odoo_service.dart';
import 'package:odoo_flutter_task/features/customers/data/models/customer_model.dart';

class CustomerRepository {
  final OdooService odooService;

  CustomerRepository(this.odooService);

  Future<List<CustomerModel>> getCustomers() async {
    final result = await odooService.callKw(
      model: 'res.partner',
      method: 'search_read',
      args: [],
      kwargs: {
        'domain': [
          ['customer_rank', '>', 0],
        ],
        'fields': [
          'id',
          'name',
          'phone',
          'email',
          'city',
          'street',
          'street2',
          'zip',
          'country_id',
        ],
      },
    );

    return (result as List)
        .map(
          (customer) =>
              CustomerModel.fromJson(Map<String, dynamic>.from(customer)),
        )
        .toList();
  }

  Future<void> updatePhone({
    required int customerId,
    required String phone,
  }) async {
    await odooService.callKw(
      model: 'res.partner',
      method: 'write',
      args: [
        [customerId],
        {'phone': phone},
      ],
    );
  }
}
