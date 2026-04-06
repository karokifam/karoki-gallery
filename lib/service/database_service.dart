import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Db? _db;
  DbCollection? _messagesCollection;
  DbCollection? _usersCollection;

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    
    final uri = dotenv.env['MONGO_URI'];
    if (uri == null || uri.isEmpty) {
      print('Warning: MONGO_URI is not set in .env');
      return;
    }

    try {
      _db = await Db.create(uri);
      await _db!.open();
      _messagesCollection = _db!.collection('messages');
      _usersCollection = _db!.collection('users');
      print('Successfully connected to MongoDB');
    } catch (e) {
      print('MongoDB connection failed: $e');
    }
  }

  Future<void> sendMessage({required String sender, required String receiver, required String text}) async {
    if (_messagesCollection == null) return;
    try {
      await _messagesCollection!.insert({
        'sender': sender,
        'receiver': receiver,
        'text': text,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getMessages(String user1, String user2) async* {
    if (_messagesCollection == null) yield [];
    
    while (true) {
      try {
        if (_messagesCollection != null && _db!.isConnected) {
          final messages = await _messagesCollection!.find(
            where.eq('sender', user1).eq('receiver', user2).or(
              where.eq('sender', user2).eq('receiver', user1)
            ).sortBy('timestamp', descending: true).limit(50)
          ).toList();
          
          yield messages;
        }
      } catch (e) {
        print('Error fetching messages: $e');
      }
      await Future.delayed(const Duration(seconds: 3)); // Poll every 3 seconds
    }
  }

  Stream<List<Map<String, dynamic>>> getGroupMessages() async* {
    if (_messagesCollection == null) yield [];
    
    while (true) {
      try {
        if (_messagesCollection != null && _db!.isConnected) {
          final messages = await _messagesCollection!.find(
            where.eq('receiver', 'GROUP').sortBy('timestamp', descending: true).limit(50)
          ).toList();
          
          yield messages;
        }
      } catch (e) {
        print('Error fetching group messages: $e');
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<bool> authenticateUser(String username, String enteredHash) async {
    if (_usersCollection == null) return false;
    try {
      final userDoc = await _usersCollection!.findOne(where.eq('username', username));
      if (userDoc != null) {
        return userDoc['passwordHash'] == enteredHash;
      } else {
        // Fallback to default hash for users not yet in the DB
        return enteredHash == '554e2a0d17af799cc802724e445443a4d55687d5776b40414e92d98fdf93a6d1';
      }
    } catch (e) {
      print('Authentication checks failed: $e');
      return false;
    }
  }

  Future<bool> updatePassword(String username, String newHash) async {
    if (_usersCollection == null) return false;
    try {
      await _usersCollection!.update(
        where.eq('username', username),
        modify.set('username', username)
              .set('passwordHash', newHash)
              .set('updatedAt', DateTime.now().toUtc().toIso8601String()),
        upsert: true,
      );
      return true;
    } catch (e) {
      print('Failed to update password: $e');
      return false;
    }
  }
}
