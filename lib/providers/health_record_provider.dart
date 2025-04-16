import 'package:flutter/foundation.dart';
import '../models/health_record.dart';
import '../services/health_record_service.dart';

class HealthRecordProvider with ChangeNotifier {
  List<HealthRecord> _healthRecords = [];
  bool _isLoading = false;

  List<HealthRecord> get healthRecords => _healthRecords;
  bool get isLoading => _isLoading;

  final HealthRecordService _healthRecordService = HealthRecordService();

  Future<void> fetchHealthRecords(String horseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthRecords = await _healthRecordService.getHealthRecords(horseId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Error fetching health records: $e');
      notifyListeners();
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      String id = await _healthRecordService.addHealthRecord(record);
      record.id = id;
      _healthRecords.add(record);
      notifyListeners();
    } catch (e) {
      print('Error adding health record: $e');
      rethrow;
    }
  }

  Future<void> updateHealthRecord(HealthRecord record) async {
    try {
      await _healthRecordService.updateHealthRecord(record);
      int index = _healthRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _healthRecords[index] = record;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating health record: $e');
      rethrow;
    }
  }

  Future<void> deleteHealthRecord(HealthRecord record) async {
    try {
      await _healthRecordService.deleteHealthRecord(record);
      _healthRecords.removeWhere((r) => r.id == record.id);
      notifyListeners();
    } catch (e) {
      print('Error deleting health record: $e');
      rethrow;
    }
  }
}
