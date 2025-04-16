import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  String name; // Changed from final to mutable
  String? region;
  DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.region,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      region: data['region'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'region': region,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
