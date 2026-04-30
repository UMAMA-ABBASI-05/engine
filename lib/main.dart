import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_endpoint_screen.dart';
import 'screens/channel_screen.dart';
import 'core/constants.dart';

void main() {
  runApp(const HealthEngineApp());
}

class HealthEngineApp extends StatelessWidget {
  const HealthEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health FHIR Engine',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryBlue),
        scaffoldBackgroundColor: AppConstants.backgroundGrey,
      ),
      home: const MainNavigationHolder(),
    );
  }
}

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DashboardScreen(), // index 0
    AddEndpointScreen(), // index 1
    ChannelsScreen(), // index 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppConstants.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: "Add Endpoint",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_component_outlined),
            activeIcon: Icon(Icons.settings_input_component),
            label: "Channels",
          ),
        ],
      ),
    );
  }
}
