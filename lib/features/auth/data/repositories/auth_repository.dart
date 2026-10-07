import 'package:odoo_flutter_task/core/constants/app_constants.dart';
import 'package:odoo_flutter_task/core/networks/odoo_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class AuthRepository {
  final OdooService odooService;

  AuthRepository(this.odooService);

  Future<OdooSession> login({
    required String username,
    required String password,
  }) async {
    return await odooService.authenticate(
      database: AppConstants.database,
      username: username,
      password: password,
    );
  }

  Future<bool> isInternalUser(int userId) async {
    final result = await odooService.callKw(
      model: 'res.users',
      method: 'has_group',
      args: [
        [userId],
        'base.group_user',
      ],
    );

    return result as bool;
  }
}
