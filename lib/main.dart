import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mad_cep/helpers/hive_helper.dart';
import 'package:mad_cep/models/medicine.dart';
import 'package:mad_cep/providers/medicine_provider.dart';
import 'package:provider/provider.dart';
import 'package:mad_cep/screens/home_screen.dart';
import 'package:mad_cep/helpers/notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MedicineAdapter());
  await HiveHelper.init();
  await NotificationHelper.initialize();

  final provider = MedicineProvider();
  await provider.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAD-CEP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
