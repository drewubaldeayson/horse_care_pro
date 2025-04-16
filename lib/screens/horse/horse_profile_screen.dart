import 'package:flutter/material.dart';
import 'package:horse_care_pro/screens/health_record/health_record_list_screen.dart';
import 'package:horse_care_pro/screens/training_record/training_record_list_screen.dart';
import 'package:provider/provider.dart';
import '../../models/horse_profile.dart';
import '../../models/health_record.dart';
import '../../models/training_record.dart';
import '../../providers/horse_provider.dart';
import '../../services/database_service.dart';
import 'add_horse_screen.dart';

class HorseProfileScreen extends StatefulWidget {
  final HorseProfile horse;

  const HorseProfileScreen({Key? key, required this.horse}) : super(key: key);

  @override
  _HorseProfileScreenState createState() => _HorseProfileScreenState();
}

class _HorseProfileScreenState extends State<HorseProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<HealthRecord> _healthRecords = [];
  List<TrainingRecord> _trainingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _healthRecords =
          await _databaseService.getHealthRecords(widget.horse.id!);
      _trainingRecords =
          await _databaseService.getTrainingRecords(widget.horse.id!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load records: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteHorse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this horse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<HorseProvider>(context, listen: false)
            .deleteHorse(widget.horse.id!, widget.horse.ownerUserId!);
        Navigator.of(context).pop(); // Return to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete horse: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.horse.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddHorseScreen(
                    existingHorse: widget.horse,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteHorse,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Horse Basic Information Card
                Card(
                  child: ListTile(
                    title: Text('Basic Information'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Breed: ${widget.horse.breed}'),
                        Text('Age: ${widget.horse.age} years'),
                        Text('Gender: ${widget.horse.gender}'),
                        if (widget.horse.weight != null)
                          Text('Weight: ${widget.horse.weight} kg'),
                        if (widget.horse.color != null)
                          Text('Color: ${widget.horse.color}'),
                      ],
                    ),
                  ),
                ),

                // Health Records Section
                SectionHeader(
                  title: 'Health Records',
                  onAddPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HealthRecordListScreen(
                          horseId: widget.horse.id!,
                          horseName: widget.horse.name,
                        ),
                      ),
                    );
                  },
                ),
                if (_healthRecords.isEmpty)
                  Center(child: Text('No health records'))
                else
                  Column(
                    children: _healthRecords.map((record) {
                      return ListTile(
                        title: Text(record.diagnosis ?? 'Health Check'),
                        subtitle: Text(
                          'Date: ${record.date.toString().split(' ')[0]}',
                        ),
                      );
                    }).toList(),
                  ),

                // Training Records Section
                SectionHeader(
                  title: 'Training Records',
                  onAddPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TrainingRecordListScreen(
                          horseId: widget.horse.id!,
                          horseName: widget.horse.name,
                        ),
                      ),
                    );
                  },
                ),
                if (_trainingRecords.isEmpty)
                  Center(child: Text('No training records'))
                else
                  Column(
                    children: _trainingRecords.map((record) {
                      return ListTile(
                        title: Text(record.trainingType),
                        subtitle: Text(
                          'Date: ${record.date.toString().split(' ')[0]}',
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAddPressed;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}
