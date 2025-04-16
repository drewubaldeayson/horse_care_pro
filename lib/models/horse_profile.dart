import 'package:cloud_firestore/cloud_firestore.dart';

class HorseProfile {
  String? id;
  String name;
  String breed;
  DateTime birthDate;
  String gender;
  double? weight;
  String? color;
  String? microchipNumber;
  String? ownerUserId;

  HorseProfile({
    this.id,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.gender,
    this.weight,
    this.color,
    this.microchipNumber,
    this.ownerUserId,
  });

  factory HorseProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle different date formats
    DateTime parseDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();

      if (dateData is Timestamp) {
        return dateData.toDate();
      }

      if (dateData is String) {
        try {
          return DateTime.parse(dateData);
        } catch (e) {
          print('Error parsing date: $dateData');
          return DateTime.now();
        }
      }

      if (dateData is DateTime) {
        return dateData;
      }

      print('Unexpected date type: ${dateData.runtimeType}');
      return DateTime.now();
    }

    return HorseProfile(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      birthDate: parseDate(data['birthDate']),
      gender: data['gender'] ?? '',
      weight: (data['weight'] as num?)?.toDouble(),
      color: data['color'],
      microchipNumber: data['microchipNumber'],
      ownerUserId: data['ownerUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'breed': breed,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'color': color,
      'microchipNumber': microchipNumber,
      'ownerUserId': ownerUserId,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'breed': breed,
      'birthDate': birthDate, // Firestore will handle conversion
      'gender': gender,
      'weight': weight,
      'color': color,
      'microchipNumber': microchipNumber,
      'ownerUserId': ownerUserId,
    };
  }

  // Age calculation
  int get age {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
