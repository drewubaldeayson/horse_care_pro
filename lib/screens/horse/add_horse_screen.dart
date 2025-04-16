import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/horse_profile.dart';
import '../../providers/horse_auth_provider.dart';
import '../../providers/horse_provider.dart';

class AddHorseScreen extends StatefulWidget {
  final HorseProfile? existingHorse;

  const AddHorseScreen({Key? key, this.existingHorse}) : super(key: key);

  @override
  _AddHorseScreenState createState() => _AddHorseScreenState();
}

class _AddHorseScreenState extends State<AddHorseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _colorController;
  late TextEditingController _microchipController;

  DateTime? _selectedBirthDate;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing horse data if editing
    _nameController =
        TextEditingController(text: widget.existingHorse?.name ?? '');
    _breedController =
        TextEditingController(text: widget.existingHorse?.breed ?? '');
    _weightController = TextEditingController(
        text: widget.existingHorse?.weight?.toString() ?? '');
    _colorController =
        TextEditingController(text: widget.existingHorse?.color ?? '');
    _microchipController = TextEditingController(
        text: widget.existingHorse?.microchipNumber ?? '');

    _selectedBirthDate = widget.existingHorse?.birthDate;
    _selectedGender = widget.existingHorse?.gender;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _saveHorse() async {
    if (_formKey.currentState!.validate()) {
      final authProvider =
          Provider.of<HorseAuthProvider>(context, listen: false);

      // Prepare horse profile
      final horseProfile = HorseProfile(
        id: widget.existingHorse?.id,
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        birthDate: _selectedBirthDate!,
        gender: _selectedGender!,
        weight: double.tryParse(_weightController.text.trim()),
        color: _colorController.text.trim(),
        microchipNumber: _microchipController.text.trim(),
        ownerUserId: authProvider.user!.uid,
      );

      try {
        // Add or update horse
        if (widget.existingHorse == null) {
          await Provider.of<HorseProvider>(context, listen: false)
              .addHorse(horseProfile, authProvider.user!.uid);
        } else {
          await Provider.of<HorseProvider>(context, listen: false)
              .updateHorse(horseProfile, authProvider.user!.uid);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Horse ${widget.existingHorse == null ? 'added' : 'updated'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(); // Return to previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save horse: $e'),
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
        title: Text(widget.existingHorse == null
            ? 'Add New Horse'
            : 'Edit Horse Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Horse Name',
                prefixIcon: Icon(Icons.pets),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter horse name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(
                labelText: 'Breed',
                prefixIcon: Icon(Icons.category),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter horse breed';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Birth Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Birth Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedBirthDate == null
                      ? 'Select Birth Date'
                      : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                ),
              ),
            ),
            SizedBox(height: 16),
            // Gender Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.transgender),
              ),
              value: _selectedGender,
              items: ['Male', 'Female']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select horse gender';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _colorController,
              decoration: InputDecoration(
                labelText: 'Color',
                prefixIcon: Icon(Icons.color_lens),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _microchipController,
              decoration: InputDecoration(
                labelText: 'Microchip Number',
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveHorse,
              child: Text(widget.existingHorse == null
                  ? 'Add Horse'
                  : 'Update Horse Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _microchipController.dispose();
    super.dispose();
  }
}
