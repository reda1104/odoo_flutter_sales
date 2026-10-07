import 'package:flutter/material.dart';
import 'package:odoo_flutter_task/features/customers/presentation/pages/customers_page.dart';

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
      appBar: AppBar(title: const Text('Main Page')),
      body: currentIndex == 0
          ? CustomersPage()
          : Center(
              child: Text("Sales Orders", style: const TextStyle(fontSize: 24)),
            ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          if (widget.isInternalUser)
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Sales',
            ),
        ],
      ),
    );
  }
}
