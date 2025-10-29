import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mad_cep/models/medicine.dart';
import 'package:mad_cep/providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _notes = TextEditingController();
  final _dose = TextEditingController(text: '1');
  String _unit = 'pills';
  String _freq = 'Daily';
  List<String> _times = []; // HH:mm
  bool _enabled = true;
  String _profile = 'Me';

  Future<void> _pickTimeAndAdd() async {
    if (_times.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 3 reminder times allowed')));
      return;
    }
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      final str = t.hour.toString().padLeft(2, '0') + ':' + t.minute.toString().padLeft(2, '0');
      setState(() => _times.add(str));
    }
  }

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<MedicineProvider>(context, listen: false);
    _profile = prov.activeProfile;
  }

  void _removeTimeAt(int i) => setState(() => _times.removeAt(i));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one reminder time')));
      return;
    }
    final prov = Provider.of<MedicineProvider>(context, listen: false);
    final med = Medicine(
      name: _name.text.trim(),
      notes: _notes.text.trim(),
      doseAmount: int.tryParse(_dose.text.trim()) ?? 1,
      doseUnit: _unit,
      frequency: _freq,
      times: _times,
      enabled: _enabled,
      status: 'pending',
      profile: _profile,
    );

    await prov.addMedicine(med);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Medicine added')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MedicineProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine'), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF4db6ac), Color(0xFF80cbc4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Medicine Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v == null || v.isEmpty ? 'Enter name' : null),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _dose, decoration: const InputDecoration(labelText: 'Dose'))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(value: _unit, items: const [
                        DropdownMenuItem(value: 'pills', child: Text('pills')),
                        DropdownMenuItem(value: 'mg', child: Text('mg')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                      ], onChanged: (v) => setState(() => _unit = v as String), decoration: const InputDecoration(labelText: 'Unit')),
                    )
                  ]),
                  const SizedBox(height: 10),
                  TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField(value: _freq, items: const [
                        DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'Once', child: Text('Once')),
                        DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      ], onChanged: (v) => setState(() => _freq = v as String), decoration: const InputDecoration(labelText: 'Frequency')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _profile,
                        items: prov.profiles.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) => setState(() => _profile = v!),
                        decoration: const InputDecoration(labelText: 'Profile'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Reminder times (max 3)'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (int i = 0; i < _times.length; i++)
                        Chip(
                          label: Text(_times[i]),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeTimeAt(i),
                        ),
                      ActionChip(
                        label: const Text('+ Add time'),
                        onPressed: _pickTimeAndAdd,
                        avatar: const Icon(Icons.access_time),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                    title: const Text('Enable reminders'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size.fromHeight(48)),
                    child: const Text('Add Medicine'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
