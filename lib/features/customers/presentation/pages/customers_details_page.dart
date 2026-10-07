import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/customers/data/models/customer_model.dart';

import 'package:odoo_flutter_task/features/customers/presentation/cubit/customer_cubit.dart';

class CustomerDetailsPage extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsPage({super.key, required this.customer});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late final TextEditingController phoneController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    phoneController = TextEditingController(text: widget.customer.phone);
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> savePhone() async {
    setState(() {
      isSaving = true;
    });

    final success = await context.read<CustomersCubit>().updatePhone(
      customerId: widget.customer.id,
      phone: phoneController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update phone')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.customer.name),

            const SizedBox(height: 20),

            const Text('Phone', style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.customer.email),

            const SizedBox(height: 20),

            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.customer.fullAddress.isEmpty
                  ? 'No address available'
                  : widget.customer.fullAddress,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : savePhone,
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Phone'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
