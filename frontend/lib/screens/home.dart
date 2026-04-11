import 'package:flutter/material.dart';
import 'package:frontend/screens/accounts/account.dart' deferred as account;
import 'package:frontend/screens/chats/contactslist.dart';
import 'package:frontend/screens/memories/binders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  String? _username; // Nullable until loaded

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Async function to load username
  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username') ?? '';
    setState(() {
      _username = storedUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show a loading indicator until username is loaded
    if (_username == null || _username!.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Screens now use the loaded username
    final List<Widget> _screens = [
      const Binders(),
      Contactslist(username: _username!),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await account.loadLibrary();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => account.AccountPage()),
              );
            },
            icon: Icon(Icons.account_circle_rounded),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.textTheme.bodyMedium!.color,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image_search_rounded),
            label: "Discover",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
        ],
      ),
    );
  }
}
