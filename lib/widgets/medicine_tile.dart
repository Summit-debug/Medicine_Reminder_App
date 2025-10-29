import 'package:flutter/material.dart';
import 'package:mad_cep/models/medicine.dart';
import 'package:mad_cep/screens/medicine_detail_screen.dart';

class MedicineTile extends StatelessWidget {
  final Medicine medicine;
  final int index; // hive index in the box
  const MedicineTile({super.key, required this.medicine, required this.index});

  Color statusColor(String s) {
    switch (s) {
      case 'taken':
        return Colors.green;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: statusColor(medicine.status),
          child: Text(medicine.name.isNotEmpty ? medicine.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${medicine.times.join(' • ')} • ${medicine.doseAmount} ${medicine.doseUnit}'),
        trailing: Icon(medicine.enabled ? Icons.notifications_active : Icons.notifications_off, color: Colors.teal),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MedicineDetailScreen(medicine: medicine, hiveIndex: index))),
      ),
    );
  }
}
