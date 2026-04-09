import 'package:flutter/material.dart';
import 'package:frontend/apis/api_service.dart'; // Your API call for password reset
// import 'package:frontend/themes/theme_controller.dart'; // Your AppTheme

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =TextEditingController();
  bool obscureText = true;
  bool _loading = false;

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    

    setState(() {
      _loading = true;
    });

    try {
      // Call your API service to reset the password
      final response = await ApiService().changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successful!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to reset password"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        hintText: "Enter your current password",
                        border: const OutlineInputBorder(),
                        suffix: IconButton(
                          onPressed: () => obscureText = !obscureText,
                          icon: obscureText
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        )
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        hintText: "Enter your new password",
                        border: const OutlineInputBorder(),
                        suffix: IconButton(
                          onPressed: () => obscureText = !obscureText,
                          icon: obscureText
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        )
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        labelText: "Confirm New Password",
                        hintText: "Re-enter new password",
                        border: const OutlineInputBorder(),
                        suffix: IconButton(
                          onPressed: () => obscureText = !obscureText,
                          icon: obscureText
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                        )
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        if (value != _newPasswordController.text)
                          return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _resetPassword,
                        child: const Text("Reset Password"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
