import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/customers/data/repositories/customer_repository.dart';
import 'package:odoo_flutter_task/features/customers/presentation/cubit/customer_cubit.dart';
import 'package:odoo_flutter_task/features/customers/presentation/pages/customers_page.dart';
import 'package:odoo_flutter_task/features/main/presentation/pages/main_page.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          CustomersCubit(context.read<CustomerRepository>()),

                      child: MainPage(isInternalUser: state.isInternalUser),
                    ),
                  ),
                );
              }

              if (state is AuthFailure) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Odoo Sales',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              context.read<AuthCubit>().login(
                                username: usernameController.text.trim(),
                                password: passwordController.text,
                              );
                            },
                      child: state is AuthLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
