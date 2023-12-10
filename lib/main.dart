import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdui_flutter_sample/form/form_notifier.dart';
import 'package:sdui_flutter_sample/form/form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChangeNotifierProvider<FormNotifier>(
        create: (BuildContext context) => FormNotifier(),
        child: const FormScreen(),
      ),
    );
  }
}
