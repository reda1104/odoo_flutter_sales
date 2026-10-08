import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_model.dart';

class CustomerCache {
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  String _cacheKey(int userId) => 'customers_cache_$userId';

  Future<void> saveCustomers({
    required int userId,
    required List<CustomerModel> customers,
  }) async {
    final customersJson = customers
        .map((customer) => customer.toJson())
        .toList();

    await prefs.setString(_cacheKey(userId), jsonEncode(customersJson));
  }

  Future<List<CustomerModel>?> getCachedCustomers(int userId) async {
    final cachedData = await prefs.getString(_cacheKey(userId));

    if (cachedData == null) {
      return null;
    }

    final decodedData = jsonDecode(cachedData) as List;

    return decodedData
        .map(
          (customer) =>
              CustomerModel.fromJson(Map<String, dynamic>.from(customer)),
        )
        .toList();
  }

  String _pendingKey(int userId) => 'pending_phones_$userId';

  Future<Map<int, String>> getPendingPhones(int userId) async {
    final data = await prefs.getString(_pendingKey(userId));

    if (data == null) return {};

    final decoded = jsonDecode(data) as Map<String, dynamic>;

    return decoded.map(
      (key, value) => MapEntry(int.parse(key), value.toString()),
    );
  }

  Future<void> _savePendingPhones(int userId, Map<int, String> updates) async {
    await prefs.setString(
      _pendingKey(userId),
      jsonEncode(updates.map((key, value) => MapEntry(key.toString(), value))),
    );
  }

  Future<void> queuePhoneUpdate({
    required int userId,
    required int customerId,
    required String phone,
  }) async {
    final updates = await getPendingPhones(userId);

    // Keep the latest phone number for each customer.
    updates[customerId] = phone;

    await _savePendingPhones(userId, updates);

    await updateCachedPhone(
      userId: userId,
      customerId: customerId,
      phone: phone,
    );
  }

  Future<void> removePendingPhone({
    required int userId,
    required int customerId,
  }) async {
    final updates = await getPendingPhones(userId);

    updates.remove(customerId);

    await _savePendingPhones(userId, updates);
  }

  Future<void> updateCachedPhone({
    required int userId,
    required int customerId,
    required String phone,
  }) async {
    final customers = await getCachedCustomers(userId);

    if (customers == null) return;

    final updatedCustomers = customers.map((customer) {
      if (customer.id != customerId) return customer;

      return CustomerModel.fromJson({...customer.toJson(), 'phone': phone});
    }).toList();

    await saveCustomers(userId: userId, customers: updatedCustomers);
  }
}
