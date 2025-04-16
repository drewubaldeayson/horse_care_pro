import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/training_record.dart';
import '../../providers/training_record_provider.dart';
import 'add_training_record_screen.dart';

class TrainingRecordListScreen extends StatefulWidget {
  final String horseId;
  final String horseName;

  const TrainingRecordListScreen({
    Key? key,
    required this.horseId,
    required this.horseName,
  }) : super(key: key);

  @override
  _TrainingRecordListScreenState createState() =>
      _TrainingRecordListScreenState();
}

class _TrainingRecordListScreenState extends State<TrainingRecordListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch records when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TrainingRecordProvider>(context, listen: false)
          .fetchTrainingRecords(widget.horseId);
    });
  }

  void _deleteTrainingRecord(TrainingRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Training Record'),
        content: Text('Are you sure you want to delete this training record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TrainingRecordProvider>(context, listen: false)
                  .deleteTrainingRecord(record);
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
        title: Text('${widget.horseName} - Training Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddTrainingRecordScreen(
                  horseId: widget.horseId,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<TrainingRecordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.trainingRecords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Training Records',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Add a training record to track your horse\'s progress',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.trainingRecords.length,
            itemBuilder: (context, index) {
              final record = provider.trainingRecords[index];
              return TrainingRecordCard(
                record: record,
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTrainingRecordScreen(
                      existingRecord: record,
                      horseId: widget.horseId,
                    ),
                  ),
                ),
                onDelete: () => _deleteTrainingRecord(record),
              );
            },
          );
        },
      ),
    );
  }
}

class TrainingRecordCard extends StatelessWidget {
  final TrainingRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TrainingRecordCard({
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
          record.trainingType,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructor: ${record.instructor ?? 'N/A'}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Date: ${record.date.day}/${record.date.month}/${record.date.year}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Duration: ${record.duration.inMinutes} minutes',
              style: TextStyle(fontSize: 12),
            ),
            if (record.performance != null)
              Text(
                'Performance: ${record.performance?.toStringAsFixed(2)}',
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
