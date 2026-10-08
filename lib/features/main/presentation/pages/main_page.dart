import 'package:flutter/material.dart';
import 'package:odoo_flutter_task/features/customers/presentation/pages/customers_page.dart';
import 'package:odoo_flutter_task/features/sales_orders/presentation/pages/sales_order_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.isInternalUser});

  final bool isInternalUser;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'Odoo Sales',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: currentIndex == 0 ? const CustomersPage() : const SalesOrderPage(),

      bottomNavigationBar: widget.isInternalUser
          ? NavigationBar(
              selectedIndex: currentIndex,
              backgroundColor: Colors.white,
              indicatorColor: Colors.blue.shade50,
              height: 72,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.people_outline, color: Colors.grey.shade600),
                  selectedIcon: Icon(Icons.people, color: Colors.blue.shade700),
                  label: 'Customers',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.grey.shade600,
                  ),
                  selectedIcon: Icon(
                    Icons.shopping_bag,
                    color: Colors.blue.shade700,
                  ),
                  label: 'Sales',
                ),
              ],
            )
          : null,
    );
  }
}
