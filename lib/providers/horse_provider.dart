import 'package:flutter/foundation.dart';
import '../models/horse_profile.dart';
import '../services/database_service.dart';

class HorseProvider with ChangeNotifier {
  List<HorseProfile> _horses = [];
  bool _isLoading = false;

  List<HorseProfile> get horses => _horses;
  bool get isLoading => _isLoading;

  final DatabaseService _databaseService = DatabaseService();

  Future<void> fetchHorses(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _horses = await _databaseService.getHorses(userId);
      print("Horses: _${horses.length.toString()}");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print('Error fetching horses: $e');
      notifyListeners();
    }
  }

  Future<void> addHorse(HorseProfile horse, String userId) async {
    try {
      // Add horse to database
      String horseId = await _databaseService.addHorse(horse, userId);

      // Update local list
      horse.id = horseId;
      _horses.add(horse);

      // Notify listeners of changes
      notifyListeners();
    } catch (e) {
      print('Error adding horse: $e');
      rethrow;
    }
  }

  Future<void> updateHorse(HorseProfile horse, String userId) async {
    try {
      await _databaseService.updateHorse(horse);

      // Find and update the horse in the local list
      int index = _horses.indexWhere((h) => h.id == horse.id);
      if (index != -1) {
        _horses[index] = horse;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating horse: $e');
      rethrow;
    }
  }

  Future<void> deleteHorse(String horseId, String userId) async {
    try {
      // Delete from database
      await _databaseService.deleteHorse(horseId, userId);

      // Remove from local list
      _horses.removeWhere((horse) => horse.id == horseId);

      // Notify listeners
      notifyListeners();
    } catch (e) {
      print('Error deleting horse in provider: $e');
      rethrow;
    }
  }
}
