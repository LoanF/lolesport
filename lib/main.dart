import 'package:flutter/material.dart';
import 'package:lolesport/classement.dart';
import 'package:lolesport/ligues.dart';
import 'package:lolesport/planning.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'root',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/ligues',
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Cours Menu'),
        '/classement': (context) => const Classement(),
        '/ligues': (context) => const Ligues(),
        '/planning': (context) => const Planning(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/classement');
              },
              child: const Text('Voir le classement'),
            ),
            const SizedBox(height: 20), // Espace entre les boutons
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/planning');
              },
              child: const Text('Voir le planning'),
            ),
          ],
        ),
      ),
    );
  }
}
