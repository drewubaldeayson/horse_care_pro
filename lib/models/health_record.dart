import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  String? id;
  String horseId;
  DateTime date;
  String veterinarian;
  String diagnosis;
  List<String> medications;
  double? weight;
  String? notes;
  bool isSerious;

  HealthRecord({
    this.id,
    required this.horseId,
    required this.date,
    required this.veterinarian,
    required this.diagnosis,
    this.medications = const [],
    this.weight,
    this.notes,
    this.isSerious = false,
  });

  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthRecord(
      id: doc.id,
      horseId: data['horseId'],
      date: (data['date'] as Timestamp).toDate(),
      veterinarian: data['veterinarian'],
      diagnosis: data['diagnosis'],
      medications: List<String>.from(data['medications'] ?? []),
      weight: (data['weight'] as num?)?.toDouble(),
      notes: data['notes'],
      isSerious: data['isSerious'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'horseId': horseId,
      'date': date,
      'veterinarian': veterinarian,
      'diagnosis': diagnosis,
      'medications': medications,
      'weight': weight,
      'notes': notes,
      'isSerious': isSerious,
    };
  }
}
