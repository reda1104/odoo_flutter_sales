import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/networks/odoo_service.dart';
import '../datasources/customer_cache.dart';
import '../models/customer_model.dart';

enum PhoneUpdateResult { synced, queued }

class CustomerRepository {
  final OdooService odooService;
  final CustomerCache customerCache = CustomerCache();
  final Connectivity connectivity = Connectivity();

  int? currentUserId;

  CustomerRepository(this.odooService);

  void setUserId(int userId) {
    currentUserId = userId;
  }

  Future<List<CustomerModel>> getCustomers() async {
    final userId = currentUserId;

    if (userId == null) {
      throw StateError('No authenticated user');
    }

    final connection = await connectivity.checkConnectivity();

    if (connection.contains(ConnectivityResult.none)) {
      final cachedCustomers = await customerCache.getCachedCustomers(userId);

      if (cachedCustomers == null) {
        throw Exception('No cached customers available');
      }

      return _applyPendingPhones(cachedCustomers, userId);
    }

    await syncPendingPhones();

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

    final customers = (result as List)
        .map(
          (customer) =>
              CustomerModel.fromJson(Map<String, dynamic>.from(customer)),
        )
        .toList();

    // Preserve unsynced changes if an update failed.
    final displayedCustomers = await _applyPendingPhones(customers, userId);

    await customerCache.saveCustomers(
      userId: userId,
      customers: displayedCustomers,
    );

    return displayedCustomers;
  }

  Future<List<CustomerModel>> _applyPendingPhones(
    List<CustomerModel> customers,
    int userId,
  ) async {
    final pending = await customerCache.getPendingPhones(userId);

    return customers.map((customer) {
      final pendingPhone = pending[customer.id];

      if (pendingPhone == null) return customer;

      return CustomerModel.fromJson({
        ...customer.toJson(),
        'phone': pendingPhone,
      });
    }).toList();
  }

  Future<PhoneUpdateResult> updatePhone({
    required int customerId,
    required String phone,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw StateError('No authenticated user');
    }

    final connection = await connectivity.checkConnectivity();

    if (connection.contains(ConnectivityResult.none)) {
      await customerCache.queuePhoneUpdate(
        userId: userId,
        customerId: customerId,
        phone: phone,
      );

      return PhoneUpdateResult.queued;
    }

    await _writePhone(customerId, phone);

    await customerCache.removePendingPhone(
      userId: userId,
      customerId: customerId,
    );

    await customerCache.updateCachedPhone(
      userId: userId,
      customerId: customerId,
      phone: phone,
    );

    return PhoneUpdateResult.synced;
  }

  Future<void> _writePhone(int customerId, String phone) async {
    final result = await odooService.callKw(
      model: 'res.partner',
      method: 'write',
      args: [
        [customerId],
        {'phone': phone},
      ],
    );

    if (result != true) {
      throw Exception('Odoo rejected the phone update');
    }
  }

  Future<void> syncPendingPhones() async {
    final userId = currentUserId;
    if (userId == null) return;

    final connection = await connectivity.checkConnectivity();

    if (connection.contains(ConnectivityResult.none)) return;

    final pending = await customerCache.getPendingPhones(userId);

    for (final entry in pending.entries) {
      try {
        await _writePhone(entry.key, entry.value);

        await customerCache.removePendingPhone(
          userId: userId,
          customerId: entry.key,
        );

        await customerCache.updateCachedPhone(
          userId: userId,
          customerId: entry.key,
          phone: entry.value,
        );

        debugPrint('Synced phone for customer ${entry.key}');
      } catch (e) {
        // Keep the edit queued so it can be retried later.
        debugPrint('Failed to sync customer ${entry.key}: $e');
      }
    }
  }
}
