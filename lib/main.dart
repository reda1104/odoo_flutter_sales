import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/customers/data/repositories/customer_repository.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/repositories/sales_order_repository.dart';

import 'core/constants/app_constants.dart';
import 'core/networks/odoo_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  final odooService = OdooService(AppConstants.odooUrl);

  final authRepository = AuthRepository(odooService);

  final customerRepository = CustomerRepository(odooService);
  final salesOrderRepository = SalesOrderRepository(odooService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: customerRepository),
        RepositoryProvider.value(value: salesOrderRepository),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo Sales',
      home: BlocProvider(
        create: (context) => AuthCubit(context.read<AuthRepository>()),
        child: const LoginPage(),
      ),
    );
  }
}
