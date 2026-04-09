import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/auth.dart';
import 'package:frontend/themes/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load login state
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username');

  runApp(
    ChangeNotifierProvider<AppTheme>(
      create: (context) => AppTheme(),
      child: KarkFam(isLoggedIn: isLoggedIn, username: username),
    ),
  );
}

class KarkFam extends StatelessWidget {
  final bool isLoggedIn;
  final String? username;

  const KarkFam({super.key, required this.isLoggedIn, this.username});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(
      builder: (context, appTheme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appTheme.themeMode,
          // Navigate based on login state
          home: isLoggedIn && username != null
              ? Home()
              : const Auth(),
        );
      },
    );
  }
}
