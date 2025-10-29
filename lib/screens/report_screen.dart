import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_cep/providers/medicine_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MedicineProvider>(context);
    final meds = prov.medicines;
    final total = meds.length;
    final taken = meds.where((m) => m.status == 'taken').length;
    final missed = meds.where((m) => m.status == 'missed').length;
    final pending = meds.where((m) => m.status == 'pending').length;
    final adherence = total == 0 ? 0.0 : (taken / total) * 100.0;

    if (total == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Adherence Report')),
        body: const Center(child: Text('No data yet — add medicines and mark them taken or missed.')),
      );
    }

    List<PieChartSectionData> sections() {
      return [
        PieChartSectionData(value: taken.toDouble(), color: Colors.green, title: 'Taken $taken'),
        PieChartSectionData(value: missed.toDouble(), color: Colors.redAccent, title: 'Missed $missed'),
        PieChartSectionData(value: pending.toDouble(), color: Colors.orange, title: 'Pending $pending'),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Adherence Report'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Adherence: ${adherence.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 220, child: PieChart(PieChartData(sections: sections(), centerSpaceRadius: 40, sectionsSpace: 2))),
          const SizedBox(height: 12),
          Wrap(spacing: 12, children: [
            Chip(label: Text('Taken: $taken'), backgroundColor: Colors.green.shade100),
            Chip(label: Text('Missed: $missed'), backgroundColor: Colors.red.shade100),
            Chip(label: Text('Pending: $pending'), backgroundColor: Colors.orange.shade100),
          ]),
          const SizedBox(height: 12),
          const Divider(),
          Expanded(
            child: ListView(
              children: meds.map((m) => ListTile(
                leading: Icon(Icons.medication, color: m.status == 'taken' ? Colors.green : m.status == 'missed' ? Colors.red : Colors.orange),
                title: Text(m.name),
                subtitle: Text('Times: ${m.times.join(' • ')}'),
                trailing: Text(m.status.toUpperCase()),
              )).toList(),
            ),
          )
        ]),
      ),
    );
  }
}
