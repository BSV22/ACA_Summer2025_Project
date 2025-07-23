import 'package:flutter/material.dart';

class Nav extends StatefulWidget {
  const Nav({super.key});

  @override
  State<Nav> createState() => _Nav();
}

class _Nav extends State<Nav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Dashboard Page')),
    Center(child: Text('Scanner Page')),
    Center(child: Text('Analytics Page')),
    Center(child: Text('Settings Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blue, // Highlight the selected item
        unselectedItemColor: Colors.grey, // Other icons/texts remain grey
        type: BottomNavigationBarType.fixed, // Keep all items visible
      ),
    );
  }
}
