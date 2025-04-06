import 'package:flutter/material.dart';
import 'components/home_dashboard_screen_body.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomeDashboardScreen'),
      ),
      body: HomeDashboardScreenBody(),
    );
  }
}
