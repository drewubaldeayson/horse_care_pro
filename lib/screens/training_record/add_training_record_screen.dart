import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/training_record.dart';
import '../../providers/training_record_provider.dart';

class AddTrainingRecordScreen extends StatefulWidget {
  final TrainingRecord? existingRecord;
  final String horseId;

  const AddTrainingRecordScreen({
    Key? key,
    this.existingRecord,
    required this.horseId,
  }) : super(key: key);

  @override
  _AddTrainingRecordScreenState createState() =>
      _AddTrainingRecordScreenState();
}

class _AddTrainingRecordScreenState extends State<AddTrainingRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final _trainingTypeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _performanceController = TextEditingController();

  Duration _duration = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    // Initialize with existing record or current date
    _selectedDate = widget.existingRecord?.date ?? DateTime.now();

    if (widget.existingRecord != null) {
      _trainingTypeController.text = widget.existingRecord!.trainingType;
      _instructorController.text = widget.existingRecord!.instructor ?? '';
      _locationController.text = widget.existingRecord!.location ?? '';
      _notesController.text = widget.existingRecord!.notes ?? '';
      _performanceController.text =
          widget.existingRecord!.performance?.toString() ?? '';
      _duration = widget.existingRecord!.duration;
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTrainingRecord() {
    if (_formKey.currentState!.validate()) {
      final trainingRecord = TrainingRecord(
        id: widget.existingRecord?.id,
        horseId: widget.horseId,
        date: _selectedDate,
        trainingType: _trainingTypeController.text.trim(),
        duration: _duration,
        instructor: _instructorController.text.trim(),
        location: _locationController.text.trim(),
        performance: double.tryParse(_performanceController.text.trim()),
        notes: _notesController.text.trim(),
      );

      try {
        if (widget.existingRecord == null) {
          // Add new record
          Provider.of<TrainingRecordProvider>(context, listen: false)
              .addTrainingRecord(trainingRecord);
        } else {
          // Update existing record
          Provider.of<TrainingRecordProvider>(context, listen: false)
              .updateTrainingRecord(trainingRecord);
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Training Record Saved Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save training record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingRecord == null
            ? 'Add Training Record'
            : 'Edit Training Record'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Training',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                ),
              ),
            ),
            SizedBox(height: 16),

            // Training Type Input
            TextFormField(
              controller: _trainingTypeController,
              decoration: InputDecoration(
                labelText: 'Training Type',
                prefixIcon: Icon(Icons.sports),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter training type';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Duration Slider
            Text('Training Duration: ${_duration.inMinutes} minutes'),
            Slider(
              value: _duration.inMinutes.toDouble(),
              min: 15,
              max: 120,
              divisions: 21,
              label: _duration.inMinutes.toString(),
              onChanged: (double value) {
                setState(() {
                  _duration = Duration(minutes: value.round());
                });
              },
            ),
            SizedBox(height: 16),

            // Instructor Input
            TextFormField(
              controller: _instructorController,
              decoration: InputDecoration(
                labelText: 'Instructor',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // Location Input
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            SizedBox(height: 16),

            // Performance Input
            TextFormField(
              controller: _performanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Performance Score',
                prefixIcon: Icon(Icons.score),
              ),
            ),
            SizedBox(height: 16),

            // Notes Input
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Additional Notes',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveTrainingRecord,
              child: Text(widget.existingRecord == null
                  ? 'Add Training Record'
                  : 'Update Training Record'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _trainingTypeController.dispose();
    _instructorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _performanceController.dispose();
    super.dispose();
  }
}
