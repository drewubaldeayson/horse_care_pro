import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_record.dart';

class HealthRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addHealthRecord(HealthRecord record) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('health_records')
          .add(record.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding health record: $e');
      rethrow;
    }
  }

  Future<List<HealthRecord>> getHealthRecords(String horseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('horses')
          .doc(horseId)
          .collection('health_records')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching health records: $e');
      return [];
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    try {
      await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('health_records')
          .doc(record.id)
          .update(record.toFirestore());
    } catch (e) {
      print('Error updating health record: $e');
      rethrow;
    }
  }

  Future<void> deleteHealthRecord(HealthRecord record) async {
    try {
      await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('health_records')
          .doc(record.id)
          .delete();
    } catch (e) {
      print('Error deleting health record: $e');
      rethrow;
    }
  }
}
