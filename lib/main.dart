import 'package:flutter/material.dart';

void main() {
  runApp(const FoundItApp());
}

// Widget utama aplikasi FoundIt.
class FoundItApp extends StatelessWidget {
  const FoundItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoundIt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 46, 131),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Center(child: Text('FoundIt'))),
        body: Center(child: Text("Lost it? Let's Find It Together.")),
      ),
    );
  }
}
