import 'package:flutter/material.dart';
import 'package:mad_cep/models/medicine.dart';
import 'package:mad_cep/providers/medicine_provider.dart';
import 'package:provider/provider.dart';
import 'add_medicine_screen.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;
  final int hiveIndex;
  const MedicineDetailScreen({super.key, required this.medicine, required this.hiveIndex});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MedicineProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to edit - a simple approach is to prefill add screen (not implemented edit screen here)
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddMedicineScreen()));
              if (result == true) prov.loadMedicines();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                title: const Text('Delete'),
                content: const Text('Delete this medicine?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
                ],
              ));
              if (ok ?? false) {
                await prov.removeMedicineAt(hiveIndex);
                if (Navigator.canPop(context)) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Dose: ${medicine.doseAmount} ${medicine.doseUnit}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Frequency: ${medicine.frequency}'),
          const SizedBox(height: 8),
          Text('Times: ${medicine.times.join(', ')}'),
          const SizedBox(height: 8),
          Text('Status: ${medicine.status}'),
          const SizedBox(height: 12),
          Text('Notes:'),
          const SizedBox(height: 6),
          Text(medicine.notes.isEmpty ? 'No notes' : medicine.notes),
          const SizedBox(height: 16),
          Row(children: [
            ElevatedButton.icon(
              onPressed: () async {
                await prov.markTakenAt(hiveIndex);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as taken')));
              },
              icon: const Icon(Icons.check),
              label: const Text('Taken'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () async {
                await prov.markMissedAt(hiveIndex);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as missed')));
              },
              icon: const Icon(Icons.close),
              label: const Text('Missed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            )
          ])
        ]),
      ),
    );
  }
}
