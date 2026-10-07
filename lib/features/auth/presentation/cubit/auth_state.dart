import 'package:odoo_rpc/odoo_rpc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final OdooSession session;

  AuthSuccess(this.session);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
