import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_cep/providers/medicine_provider.dart';
import 'package:mad_cep/screens/add_medicine_screen.dart';
import 'package:mad_cep/widgets/medicine_tile.dart';
import 'package:mad_cep/screens/report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MedicineProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MAD-CEP — Medicine Reminder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Adherence report',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export CSV',
            onPressed: () async {
              final path = await prov.exportCsv();
              if (!context.mounted) return;
              if (path == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export started (web download).')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported: $path')));
              }
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicineScreen()));
          prov.loadMedicines();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0f2f1), Color(0xFF80cbc4), Color(0xFF4db6ac)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // header card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _Header(prov: prov),
              ),
              Expanded(
                child: prov.medicines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/logo.png', width: 140, height: 140),
                            const SizedBox(height: 12),
                            const Text('No medicines yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text('Tap + to add medicines for this profile.'),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: prov.medicines.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => MedicineTile(
                          medicine: prov.medicines[i],
                          index: i,
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MedicineProvider prov;
  const _Header({required this.prov, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Welcome', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(prov.activeProfile, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('${prov.medicines.length} medicines', style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.person, color: Colors.white),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              value: prov.activeProfile,
              items: prov.profiles.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) {
                if (v == null) return;
                prov.switchProfile(v);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () async {
              final name = await showDialog<String>(
                context: context,
                builder: (ctx) {
                  String tmp = '';
                  return AlertDialog(
                    title: const Text('Create profile'),
                    content: TextField(onChanged: (s) => tmp = s.trim(), decoration: const InputDecoration(hintText: 'Profile name')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, tmp), child: const Text('Create')),
                    ],
                  );
                },
              );
              if (name != null && name.isNotEmpty) {
                prov.addProfile(name);
                prov.switchProfile(name);
              }
            },
          ),
        ]),
      ),
    ]);
  }
}
