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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Phone updated successfully' : 'Failed to update phone',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'Customer Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.blue.shade50,
              child: Icon(
                Icons.person_outline,
                size: 44,
                color: Colors.blue.shade700,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              customer.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 22),

                  _buildInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Name',
                    value: customer.name,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Phone',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: Colors.blue.shade700,
                      ),
                      hintText: 'Enter phone number',
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: customer.email.isEmpty
                        ? 'No email available'
                        : customer.email,
                  ),

                  const SizedBox(height: 20),

                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: customer.fullAddress.isEmpty
                        ? 'No address available'
                        : customer.fullAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSaving ? null : savePhone,
                icon: isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Icons.save_outlined),
                label: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Phone',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue.shade700, size: 21),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
