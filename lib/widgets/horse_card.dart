import 'package:flutter/material.dart';
import 'package:horse_care_pro/providers/horse_auth_provider.dart';
import 'package:horse_care_pro/providers/horse_provider.dart';
import 'package:provider/provider.dart';
import '../models/horse_profile.dart';
import '../screens/horse/horse_profile_screen.dart';
import '../screens/health_record/health_record_list_screen.dart';
import '../screens/training_record/training_record_list_screen.dart';

class HorseCard extends StatelessWidget {
  final HorseProfile horse;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HorseCard({
    Key? key,
    required this.horse,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  void _deleteHorse(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Horse'),
        content: Text(
            'Are you sure you want to delete ${horse.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Close the dialog
              Navigator.of(context).pop();

              // Get user ID
              final userId =
                  Provider.of<HorseAuthProvider>(context, listen: false)
                      .user
                      ?.uid;

              if (userId != null) {
                // Attempt to delete horse
                Provider.of<HorseProvider>(context, listen: false)
                    .deleteHorse(horse.id!, userId)
                    .then((_) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${horse.name} has been deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((error) {
                  // Show error message if deletion fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete horse: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HorseProfileScreen(horse: horse),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Horse Avatar/Icon
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.pets,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  // Horse Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horse.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[800],
                                  ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${horse.breed} • ${horse.gender}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.brown[600]),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Age: ${horse.age} years',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.brown[500]),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteHorse(context),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Quick Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionButton(
                    context,
                    icon: Icons.medical_services,
                    label: 'Health',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HealthRecordListScreen(
                            horseId: horse.id!,
                            horseName: horse.name,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionButton(
                    context,
                    icon: Icons.sports,
                    label: 'Training',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TrainingRecordListScreen(
                            horseId: horse.id!,
                            horseName: horse.name,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
