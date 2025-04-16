import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/horse_profile.dart';
import '../models/health_record.dart';
import '../models/training_record.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Horse Operations
  Future<String> addHorse(HorseProfile horse, String userId) async {
    try {
      // Add horse to user's horses collection
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('horses')
          .add(horse.toJson());

      return docRef.id;
    } catch (e) {
      print('Error adding horse: $e');
      rethrow;
    }
  }

  Future<List<HorseProfile>> getHorses(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('horses')
          .get();

      return snapshot.docs
          .map((doc) => HorseProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching horses: $e');
      return [];
    }
  }

  Future<void> updateHorse(HorseProfile horse) async {
    try {
      await _firestore
          .collection('users')
          .doc(horse.ownerUserId)
          .collection('horses')
          .doc(horse.id)
          .update(horse.toJson());
    } catch (e) {
      print('Error updating horse: $e');
      rethrow;
    }
  }

  Future<void> deleteHorse(String horseId, String userId) async {
  try {
    // Delete the horse document
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('horses')
        .doc(horseId)
        .delete();

    // Optional: Delete subcollections if needed
    // Delete health records
    QuerySnapshot healthRecords = await _firestore
        .collection('horses')
        .doc(horseId)
        .collection('health_records')
        .get();
    
    for (DocumentSnapshot doc in healthRecords.docs) {
      await doc.reference.delete();
    }

    // Delete training records
    QuerySnapshot trainingRecords = await _firestore
        .collection('horses')
        .doc(horseId)
        .collection('training_records')
        .get();
    
    for (DocumentSnapshot doc in trainingRecords.docs) {
      await doc.reference.delete();
    }

    print('Horse and associated records deleted successfully');
  } catch (e) {
    print('Error deleting horse: $e');
    rethrow;
  }
}

  // Health Record Operations
  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('health_records')
          .add(record.toFirestore());
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
          .get();

      return snapshot.docs
          .map((doc) => HealthRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching health records: $e');
      return [];
    }
  }

  // Training Record Operations
  Future<void> addTrainingRecord(TrainingRecord record) async {
    try {
      await _firestore
          .collection('horses')
          .doc(record.horseId)
          .collection('training_records')
          .add(record.toFirestore());
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
          .get();

      return snapshot.docs
          .map((doc) => TrainingRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching training records: $e');
      return [];
    }
  }
}
