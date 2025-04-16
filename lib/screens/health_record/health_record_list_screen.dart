import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/health_record.dart';
import '../../providers/health_record_provider.dart';
import 'add_health_record_screen.dart';

class HealthRecordListScreen extends StatefulWidget {
  final String horseId;
  final String horseName;

  const HealthRecordListScreen({
    Key? key,
    required this.horseId,
    required this.horseName,
  }) : super(key: key);

  @override
  _HealthRecordListScreenState createState() => _HealthRecordListScreenState();
}

class _HealthRecordListScreenState extends State<HealthRecordListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch records when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthRecordProvider>(context, listen: false)
          .fetchHealthRecords(widget.horseId);
    });
  }

  void _deleteHealthRecord(HealthRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Health Record'),
        content: Text('Are you sure you want to delete this health record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<HealthRecordProvider>(context, listen: false)
                  .deleteHealthRecord(record);
              Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.horseName} - Health Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddHealthRecordScreen(
                  horseId: widget.horseId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<HealthRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.healthRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Health Records',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Add a health record to track your horse\'s wellness',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.healthRecords.length,
            itemBuilder: (context, index) {
              final record = provider.healthRecords[index];
              return HealthRecordCard(
                record: record,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddHealthRecordScreen(
                      existingRecord: record,
                      horseId: widget.horseId,
                    ),
                  ),
                ),
                onDelete: () => _deleteHealthRecord(record),
              );
            },
          );
        },
      ),
    );
  }
}

class HealthRecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HealthRecordCard({
    Key? key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(
          record.diagnosis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: record.isSerious ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veterinarian: ${record.veterinarian}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Date: ${record.date.day}/${record.date.month}/${record.date.year}',
              style: TextStyle(fontSize: 12),
            ),
            if (record.medications.isNotEmpty)
              Text(
                'Medications: ${record.medications.join(", ")}',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
