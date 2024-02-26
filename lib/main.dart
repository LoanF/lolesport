import 'package:flutter/material.dart';
import 'package:lolesport/classement.dart';
import 'package:lolesport/home.dart';
import 'package:lolesport/planning.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LolEsport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const MyHomePage(title: 'LolEsport'),
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
  int _selectedDrawerIndex = 1;
  late Future ligue;
  late Object dropdownValue;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final pref = prefs.getString('idLeague');
    dropdownValue = pref ?? "98767991302996019";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    ligue = fetch(
      'https://esports-api.lolesports.com/persisted/gw/getLeagues?hl=fr-FR',
      ligueFormat,
    );
  }

  dynamic ligueFormat(Map res) {
    return res["data"]["leagues"];
  }

  Future fetch(String url, dynamic Function(Map) format) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept-Charset': 'utf-8',
        'x-api-key': '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',
      },
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> decodedData = jsonDecode(responseBody);
      return format(decodedData);
    } else {
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return const Planning();
      case 1:
        return const Home();
      case 2:
        return Classement(idLeague: dropdownValue.toString());
      default:
        return const Text("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedDrawerIndex,
        backgroundColor: const Color.fromARGB(221, 54, 53, 53),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        onTap: (int index) {
          setState(() {
            _selectedDrawerIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reorder),
            label: 'Classement',
          ),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 54, 53, 53),
        foregroundColor: Colors.white,
        title: FutureBuilder(
          future: ligue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DropdownButtonHideUnderline(
                child: DropdownButton(
                  dropdownColor: const Color.fromARGB(221, 54, 53, 53),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  value: dropdownValue,
                  isExpanded: true,
                  items: snapshot.data!.map<DropdownMenuItem<Object>>((item) {
                    return DropdownMenuItem(
                      value: item['id'],
                      child: Row(
                        children: [
                          Image(
                            image: NetworkImage(item['image']),
                            height: 40.0,
                            width: 40.0,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                item['region'],
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      dropdownValue = value!;
                      prefs.setString('idLeague', dropdownValue.toString());
                    });
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator.adaptive();
          },
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
