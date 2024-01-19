import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Classement extends StatefulWidget {
  const Classement({super.key});

  @override
  State<Classement> createState() => _WeatherSimulatorState();
}

class _WeatherSimulatorState extends State<Classement> {
  late Future classement;
  @override
  void initState() {
    super.initState();
    classement = fetch(
        'https://esports-api.lolesports.com/persisted/gw/getStandingsV3?hl=fr-FR&tournamentId=111560983131400452');
    // Start the simulation when the widget is initialized
  }

  Future fetch(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',
      },
    );

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body) as Map<String, dynamic>;
      return res["data"]["standings"][0]["stages"][0]["sections"][0]
          ["rankings"];
    } else {
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEC Classement'),
      ),
      body: Center(
        child: FutureBuilder(
          future: classement,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Map item = snapshot.data[index];
                    return ListBody(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Rank: ${item['ordinal']}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        for (Map team in item['teams'])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              "- ${team['name']}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
      bottomSheet: Container(
        color: Colors.white, // Couleur de fond transparente
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
