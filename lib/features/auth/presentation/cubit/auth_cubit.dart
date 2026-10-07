import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/auth/data/repositories/auth_repository.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final session = await authRepository.login(
        username: username,
        password: password,
      );

      emit(AuthSuccess(session));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
