import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  final List<String> availableUsers = const [
    'marykaroki',
    'brendakaroki',
    'daisykaroki',
    'kenkaroki',
    'dianakaroki',
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

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _selectedUser!);

        // Navigate to Home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        // Show error message from API
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
              items: availableUsers.map((String user) {
                return DropdownMenuItem<String>(value: user, child: Text(user));
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
                suffix: IconButton(onPressed: ()=> obscureText=!obscureText, icon: obscureText?Icon(Icons.visibility): Icon(Icons.visibility_off))
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
