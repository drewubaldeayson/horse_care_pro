import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_record.dart';

class TrainingRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addTrainingRecord(TrainingRecord record) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('training_records')
          .add(record.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding training record: $e');
      rethrow;
    }
  }

  Future<List<TrainingRecord>> getTrainingRecords(String horseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('horses')
          .doc(horseId)
          .collection('training_records')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching training records: $e');
      return [];
    }
  }

  Future<void> updateTrainingRecord(TrainingRecord record) async {
    try {
      await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('training_records')
          .doc(record.id)
          .update(record.toFirestore());
    } catch (e) {
      print('Error updating training record: $e');
      rethrow;
    }
  }

  Future<void> deleteTrainingRecord(TrainingRecord record) async {
    try {
      await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('training_records')
          .doc(record.id)
          .delete();
    } catch (e) {
      print('Error deleting training record: $e');
      rethrow;
    }
  }
}
