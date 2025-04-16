import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingRecord {
  String? id;
  String horseId;
  DateTime date;
  String trainingType;
  Duration duration;
  String? instructor;
  String? location;
  double? performance;
  String? notes;

  TrainingRecord({
    this.id,
    required this.horseId,
    required this.date,
    required this.trainingType,
    required this.duration,
    this.instructor,
    this.location,
    this.performance,
    this.notes,
  });

  factory TrainingRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TrainingRecord(
      id: doc.id,
      horseId: data['horseId'],
      date: (data['date'] as Timestamp).toDate(),
      trainingType: data['trainingType'],
      duration: Duration(minutes: data['duration']),
      instructor: data['instructor'],
      location: data['location'],
      performance: (data['performance'] as num?)?.toDouble(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'horseId': horseId,
      'date': date,
      'trainingType': trainingType,
      'duration': duration.inMinutes,
      'instructor': instructor,
      'location': location,
      'performance': performance,
      'notes': notes,
    };
  }
}
