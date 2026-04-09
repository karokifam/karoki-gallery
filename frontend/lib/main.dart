import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/auth.dart';
import 'package:frontend/themes/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/apis/api_service.dart';

const String _apiUrl = '${ApiService.baseUrl}/startup';
const Duration _interval = Duration(seconds: 60);

// Defined at top level, outside main()
Future<void> _keepAliveServer() async {
  try {
    final response = await http.get(Uri.parse(_apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('[${DateTime.now()}] Response: $data');
    } else {
      print('[${DateTime.now()}] Error: status code ${response.statusCode}');
    }
  } catch (e) {
    print('[${DateTime.now()}] Exception: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Call once immediately, then schedule periodic pings
  await _keepAliveServer();
  Timer.periodic(_interval, (_) => _keepAliveServer());

  // App startup logic stays in main(), not inside the keep-alive function
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
          home: isLoggedIn && username != null ? Home() : const Auth(),
        );
      },
    );
  }
}
