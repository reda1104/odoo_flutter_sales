import 'package:odoo_rpc/odoo_rpc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final OdooSession session;
  final bool isInternalUser;

  AuthSuccess(this.session, this.isInternalUser);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
