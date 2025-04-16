import 'package:flutter/foundation.dart';
import '../models/training_record.dart';
import '../services/training_record_service.dart';

class TrainingRecordProvider with ChangeNotifier {
  List<TrainingRecord> _trainingRecords = [];
  bool _isLoading = false;

  List<TrainingRecord> get trainingRecords => _trainingRecords;
  bool get isLoading => _isLoading;

  final TrainingRecordService _trainingRecordService = TrainingRecordService();

  Future<void> fetchTrainingRecords(String horseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _trainingRecords =
          await _trainingRecordService.getTrainingRecords(horseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Error fetching training records: $e');
      notifyListeners();
    }
  }

  Future<void> addTrainingRecord(TrainingRecord record) async {
    try {
      String id = await _trainingRecordService.addTrainingRecord(record);
      record.id = id;
      _trainingRecords.add(record);
      notifyListeners();
    } catch (e) {
      print('Error adding training record: $e');
      rethrow;
    }
  }

  Future<void> updateTrainingRecord(TrainingRecord record) async {
    try {
      await _trainingRecordService.updateTrainingRecord(record);
      int index = _trainingRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _trainingRecords[index] = record;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating training record: $e');
      rethrow;
    }
  }

  Future<void> deleteTrainingRecord(TrainingRecord record) async {
    try {
      await _trainingRecordService.deleteTrainingRecord(record);
      _trainingRecords.removeWhere((r) => r.id == record.id);
      notifyListeners();
    } catch (e) {
      print('Error deleting training record: $e');
      rethrow;
    }
  }
}
