import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import '../components/neumorphic_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: NeumorphicAppBar(
        title: const Text(
          'Tariq Eye Corner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        color: Colors.lightBlue[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            NeumorphicDashboardButton(
              icon: Icons.person_add,
              label: 'Add Customer',
              onTap: () {},
            ),
            NeumorphicDashboardButton(
              icon: Icons.search,
              label: 'Search Customer',
              onTap: () {},
            ),
            NeumorphicDashboardButton(
              icon: Icons.build,
              label: 'Add Repairing Customer',
              onTap: () {},
            ),
            NeumorphicDashboardButton(
              icon: Icons.bar_chart,
              label: 'Sales',
              onTap: () {},
            ),
            NeumorphicDashboardButton(
              icon: Icons.storefront,
              label: 'My Shop',
              onTap: () {},
            ),
            NeumorphicDashboardButton(
              icon: Icons.power_settings_new,
              label: 'Logout',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
