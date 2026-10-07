import 'package:odoo_rpc/odoo_rpc.dart';

class OdooService {
  final OdooClient client;

  OdooService(String baseUrl) : client = OdooClient(baseUrl);

  Future<OdooSession> authenticate({
    required String database,
    required String username,
    required String password,
  }) async {
    return await client.authenticate(database, username, password);
  }

  Future<dynamic> callKw({
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    return await client.callKw({
      'model': model,
      'method': method,
      'args': args,
      'kwargs': kwargs,
    });
  }
}
