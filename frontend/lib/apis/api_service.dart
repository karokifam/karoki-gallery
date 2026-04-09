import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for debugPrint

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  /// ---------------------- Login function ---------------------------------------
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save username locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        return {
          "success": true,
          "message": data["message"] ?? "Login successful",
        };
      } else {
        return {"success": false, "message": data["message"] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  
  /// --------------------------- Change user password ----------------------------------
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    String? username, 
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/change_password');
      final prefs = await SharedPreferences.getInstance();
      username ??= prefs.getString('username');

      final body = jsonEncode({
        "username": username ?? "default_username",
        "old_password": oldPassword,
        "new_password": newPassword,
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        return {"success": true, "message": "Password changed successfully"};
      } else {
        final resp = jsonDecode(response.body);
        return {
          "success": false,
          "message": resp["message"] ?? "Failed to change password",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// -------- LOAD MESSAGES --------
  static Future<List<dynamic>> loadMessages(sender , recipient) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/messages/get/$sender/$recipient"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // must be a List
      } else {
        throw Exception("Failed to load messages");
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
      return [];
    }
  }
  static Future<List<dynamic>> loadgroupMessages() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/messages/get_group_chats"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // must be a List
      } else {
        throw Exception("Failed to load messages");
      }
    } catch (e) {
      debugPrint("Error loading messages: $e");
      return [];
    }
  }

  /// -------- SEND MESSAGE --------
  static Future<void> sendMessage(String message , String sender , String recipient) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/messages/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender": sender,
          "receiver":recipient,
          "message": message
          }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send message");
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

/// ----- get binders ---------
static Future<List<dynamic>> getBinders() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/folders"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load binders");
      }
    } catch (e) {
      throw Exception("API error: $e");
    }
  }

  /// --------- Fetch media inside a binder ---------
  static Future<List<dynamic>> getMedia(String binderPath) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/media/$binderPath"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load media");
      }
    } catch (e) {
      throw Exception("API error: $e");
    }
  }

  /// -------- ADD BINDER --------
  static Future<void> addBinder(String binderName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/folders"), // Assuming POST to /folders creates a new one
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": binderName}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to add binder: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error adding binder: $e");
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  // ----------- delete memory -----------
  Future<String> delete_memory(memory , deleter)async{
     try {
      final response = await http.post(
        Uri.parse("$baseUrl/media/delete"), // Assuming POST to /folders creates a new one
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"deleter": deleter, "memory":memory }),
      );


      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to delete: ${response.statusCode}");
      }

      return jsonDecode(response.body)['status'];
    } catch (e) {
      debugPrint("Error  deleting: $e");
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  /// ------------------------- poll ----------------

  void pollvoting(voter , vote_type ,poll_id)async{
     try {
      final response = await http.post(
        Uri.parse("$baseUrl/media/delete_poll"), // Assuming POST to /folders creates a new one
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"voter": voter, "vote_type":vote_type , "poll_id":poll_id }),
      );


      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Failed to delete: ${response.statusCode}");
      }

      
    } catch (e) {
      debugPrint("Error adding deleting: $e");
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  

}
