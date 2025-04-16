import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_record.dart';
import '../../providers/health_record_provider.dart';

class AddHealthRecordScreen extends StatefulWidget {
  final HealthRecord? existingRecord;
  final String horseId;

  const AddHealthRecordScreen({
    Key? key,
    this.existingRecord,
    required this.horseId,
  }) : super(key: key);

  @override
  _AddHealthRecordScreenState createState() => _AddHealthRecordScreenState();
}

class _AddHealthRecordScreenState extends State<AddHealthRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  final _veterinarianController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicationController = TextEditingController();

  List<String> _medications = [];
  bool _isSerious = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing record or current date
    _selectedDate = widget.existingRecord?.date ?? DateTime.now();

    if (widget.existingRecord != null) {
      _veterinarianController.text = widget.existingRecord!.veterinarian;
      _diagnosisController.text = widget.existingRecord!.diagnosis;
      _notesController.text = widget.existingRecord!.notes ?? '';
      _weightController.text = widget.existingRecord!.weight?.toString() ?? '';
      _medications = widget.existingRecord!.medications;
      _isSerious = widget.existingRecord!.isSerious;
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

  void _addMedication() {
    if (_medicationController.text.isNotEmpty) {
      setState(() {
        _medications.add(_medicationController.text.trim());
        _medicationController.clear();
      });
    }
  }

  void _saveHealthRecord() {
    if (_formKey.currentState!.validate()) {
      final healthRecord = HealthRecord(
        id: widget.existingRecord?.id,
        horseId: widget.horseId,
        date: _selectedDate,
        veterinarian: _veterinarianController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        medications: _medications,
        weight: double.tryParse(_weightController.text.trim()),
        notes: _notesController.text.trim(),
        isSerious: _isSerious,
      );

      try {
        if (widget.existingRecord == null) {
          // Add new record
          Provider.of<HealthRecordProvider>(context, listen: false)
              .addHealthRecord(healthRecord);
        } else {
          // Update existing record
          Provider.of<HealthRecordProvider>(context, listen: false)
              .updateHealthRecord(healthRecord);
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health Record Saved Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save health record: $e'),
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
            ? 'Add Health Record'
            : 'Edit Health Record'),
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
                  labelText: 'Date of Health Check',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                ),
              ),
            ),
            SizedBox(height: 16),

            // Veterinarian Input
            TextFormField(
              controller: _veterinarianController,
              decoration: InputDecoration(
                labelText: 'Veterinarian Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter veterinarian name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Diagnosis Input
            TextFormField(
              controller: _diagnosisController,
              decoration: InputDecoration(
                labelText: 'Diagnosis',
                prefixIcon: Icon(Icons.medical_services),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter diagnosis';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Medications Section
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _medicationController,
                    decoration: InputDecoration(
                      labelText: 'Medication',
                      prefixIcon: Icon(Icons.medication),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: _addMedication,
                ),
              ],
            ),
            // Medications List
            if (_medications.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _medications.map((med) {
                  return Chip(
                    label: Text(med),
                    onDeleted: () {
                      setState(() {
                        _medications.remove(med);
                      });
                    },
                  );
                }).toList(),
              ),
            SizedBox(height: 16),

            // Weight Input
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
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
            SizedBox(height: 16),

            // Serious Condition Checkbox
            SwitchListTile(
              title: Text('Serious Condition'),
              value: _isSerious,
              onChanged: (bool value) {
                setState(() {
                  _isSerious = value;
                });
              },
            ),
            SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveHealthRecord,
              child: Text(widget.existingRecord == null
                  ? 'Add Health Record'
                  : 'Update Health Record'),
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
    _veterinarianController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _medicationController.dispose();
    super.dispose();
  }
}
