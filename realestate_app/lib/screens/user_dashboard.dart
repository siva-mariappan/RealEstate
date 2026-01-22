import 'package:flutter/material.dart';
import 'my_properties.dart';
import 'favourites_tab.dart';
import 'messages_tab.dart';
import 'profile_tab.dart';

// ✅ RENAMED: Changed from UserDashboardScreen to UserDashboard
class UserDashboard extends StatefulWidget {
  final int initialTab;
  
  const UserDashboard({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

// ✅ RENAMED: Changed from _UserDashboardScreenState to _UserDashboardState
class _UserDashboardState extends State<UserDashboard> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const MyPropertiesTab(),
    const FavouritesTab(),
    const MessagesTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

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
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'My Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}