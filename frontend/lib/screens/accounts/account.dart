import 'package:flutter/material.dart';
import 'package:frontend/screens/auth.dart';
import 'package:provider/provider.dart';
import 'package:frontend/themes/theme_controller.dart';
import 'package:frontend/screens/accounts/password_reset_screen.dart'
    deferred as passwordPage;
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? display_username; // Nullable until loaded

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Async function to load username
  void _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('display_username') ?? '';
    setState(() {
      display_username = storedUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<AppTheme>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            CircleAvatar(
              radius: 50,
              backgroundColor: theme.primaryColor,
              child: Text(
                (display_username ?? '').substring(0, 1).toUpperCase(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              display_username ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            // 🔐 CHANGE PASSWORD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_reset),
                label: const Text("Change Password"),
                style: theme.elevatedButtonTheme.style,
                onPressed: () async {
                  await passwordPage.loadLibrary();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => passwordPage.PasswordResetPage(),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            const SizedBox(height: 12),

            // 🚪 LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: theme.elevatedButtonTheme.style,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            // 🔥 CLEAR SHARED PREFERENCES
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();

                            // 🚀 NAVIGATE TO LOGIN & REMOVE ALL PREVIOUS SCREENS
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Auth(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
