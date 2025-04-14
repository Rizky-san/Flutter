// lib/service/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.get('role');
      } else {
        return null;
      }
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }
}
