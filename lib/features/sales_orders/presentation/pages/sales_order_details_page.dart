import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/models/sales_order_line_model.dart';
import 'package:odoo_flutter_task/features/sales_orders/data/models/sales_order_model.dart';
import 'package:odoo_flutter_task/features/sales_orders/presentation/cubit/sales_order_cubit.dart';

class SalesOrderDetailsPage extends StatefulWidget {
  final SalesOrderModel salesOrder;

  const SalesOrderDetailsPage({super.key, required this.salesOrder});

  @override
  State<SalesOrderDetailsPage> createState() => _SalesOrderDetailsPageState();
}

class _SalesOrderDetailsPageState extends State<SalesOrderDetailsPage> {
  late Future<List<SalesOrderLineModel>> orderLinesFuture;

  bool isConfirming = false;

  @override
  void initState() {
    super.initState();

    orderLinesFuture = context.read<SalesOrderCubit>().getSalesOrderLines(
      widget.salesOrder.orderLineIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.salesOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Details',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(order.status),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order Number',
                  value: order.orderNumber,
                ),

                const SizedBox(height: 20),

                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Customer',
                  value: order.customerName,
                ),

                const SizedBox(height: 20),

                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Order Date',
                  value: order.orderDate,
                ),

                const SizedBox(height: 20),

                _buildInfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Total',
                  value: order.total.toStringAsFixed(2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Products',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          FutureBuilder<List<SalesOrderLineModel>>(
            future: orderLinesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline),
                      SizedBox(width: 12),
                      Text(
                        'Unable to load products',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              final lines = snapshot.data ?? [];

              if (lines.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              return Column(
                children: lines.map((line) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.blue.shade700,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.productName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Quantity: ${line.quantity}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                'Unit Price: ${line.unitPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          line.subtotal.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          if (order.status == 'draft' || order.status == 'sent') ...[
            const SizedBox(height: 20),

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
                onPressed: isConfirming
                    ? null
                    : () async {
                        setState(() {
                          isConfirming = true;
                        });

                        final success = await context
                            .read<SalesOrderCubit>()
                            .confirmSalesOrder(order.id);

                        if (!mounted) return;

                        setState(() {
                          isConfirming = false;
                        });

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order confirmed successfully'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to confirm order'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: isConfirming
                    ? const SizedBox.shrink()
                    : const Icon(Icons.check_circle_outline),
                label: isConfirming
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Order',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
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

  Widget _buildStatusBadge(String status) {
    String text;

    switch (status) {
      case 'draft':
        text = 'Draft';
        break;

      case 'sent':
        text = 'Quotation Sent';
        break;

      case 'sale':
        text = 'Confirmed';
        break;

      case 'cancel':
        text = 'Cancelled';
        break;

      default:
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
