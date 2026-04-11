import 'package:flutter/material.dart';
import 'package:frontend/apis/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  String? _selectedUser;
  final _passwordController = TextEditingController();
  bool obscureText = true;

  // Fix 1 & 2: lowercase `dynamic` and closed generic brackets
  final List<List<dynamic>> availableUsers = const [
    ['Wangechi Shima', 'marykaroki'],
    ['Brenda Karoki', 'brendakaroki'],
    ['Daisy Karoki', 'daisykaroki'],
    ['Ken Karoki', 'kenkaroki'],
    ['Diana Karoki', 'dianakaroki'],
  ];

  Future<void> _login() async {
    if (_selectedUser == null || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a user and enter password"),
        ),
      );
      return;
    }

    try {
      final loginStatus = await ApiService().login(
        username: _selectedUser!,
        password: _passwordController.text,
      );

      if (loginStatus['success'] == true) {
        debugPrint('Selected User: $_selectedUser');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _selectedUser!);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginStatus['message'] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedUser,
              decoration: InputDecoration(
                labelText: 'Select User',
                border: const OutlineInputBorder(),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
              ),
              // Fix 3: use index 1 as value (username), index 0 as label (display name)
              items: availableUsers.map((user) {
                return DropdownMenuItem<String>(
                  value: user[1] as String,
                  child: Text(user[0] as String),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUser = newValue;
                });
              },
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
                // Fix 4: wrap toggle in setState
                suffix: IconButton(
                  onPressed: () => setState(() => obscureText = !obscureText),
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text("LOGIN"),
            ),
          ],
        ),
      ),
    );
  }
}
