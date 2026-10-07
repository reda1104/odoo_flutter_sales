import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/customers/presentation/cubit/customer_cubit.dart';
import 'package:odoo_flutter_task/features/customers/presentation/cubit/customer_state.dart';
import 'package:odoo_flutter_task/features/customers/presentation/pages/customers_details_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  void initState() {
    super.initState();

    context.read<CustomersCubit>().getCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                context.read<CustomersCubit>().searchCustomers(value);
              },
            ),
          ),

          Expanded(
            child: BlocBuilder<CustomersCubit, CustomersState>(
              builder: (context, state) {
                if (state is CustomersLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CustomersFailure) {
                  return Center(child: Text(state.message));
                }

                if (state is CustomersSuccess) {
                  if (state.customers.isEmpty) {
                    return const Center(child: Text('No customers found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () {
                      return context.read<CustomersCubit>().getCustomers();
                    },
                    child: ListView.builder(
                      itemCount: state.customers.length,
                      itemBuilder: (context, index) {
                        final customer = state.customers[index];

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(customer.name),
                          subtitle: Text(
                            '${customer.phone}\n${customer.fullAddress}',
                          ),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CustomersCubit>(),
                                  child: CustomerDetailsPage(
                                    customer: customer,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
