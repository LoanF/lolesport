import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Planning extends StatefulWidget {
  const Planning({super.key});

  @override
  State<Planning> createState() => _WeatherSimulatorState();
}

class _WeatherSimulatorState extends State<Planning> {
  late Future planning;

  @override
  void initState() {
    super.initState();
    String LECId = '98767991302996019';
    planning = fetch(
        'https://esports-api.lolesports.com/persisted/gw/getSchedule?hl=fr-FR&leagueId=$LECId');
  }

  Future fetch(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> res =
          jsonDecode(response.body) as Map<String, dynamic>;
      List<Map<String, dynamic>> events =
          res["data"]["schedule"]["events"].cast<Map<String, dynamic>>();
      return events;
    } else {
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEC planning'),
      ),
      body: Center(
        child: FutureBuilder(
          future: planning,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: (snapshot.data as List<dynamic>).length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> event =
                        (snapshot.data as List<dynamic>)[index];

                    String startTime = event['startTime'] ?? '';
                    String formattedTime = _formatTime(startTime);
                    String leagueName = event['league']['name'] ?? '';

                    List<Map<String, dynamic>> teams =
                        (event['match']['teams'] as List<dynamic>?)
                                ?.cast<Map<String, dynamic>>() ??
                            [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side - Formatted time
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            // Middle - Team logos and vs
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        teams[0]['image'],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        '${teams[0]['name']}',
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'vs',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        teams[1]['image'],
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        '${teams[1]['name']}',
                                        style: const TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Right side - League
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  leagueName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
        color: Colors.white,
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

  String _formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }
}
