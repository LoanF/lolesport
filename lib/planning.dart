import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Planning extends StatefulWidget {
  const Planning({Key? key});

  @override
  State<Planning> createState() => _WeatherSimulatorState();
}

class _WeatherSimulatorState extends State<Planning> {
  late Future planning;
  late Future leagues;
  Map? league;
  late String leagueSlug = '';

  @override
  void initState() {
    super.initState();
    String leagueId = '105266103462388553'; //LFL
    planning = fetch(
        'https://esports-api.lolesports.com/persisted/gw/getSchedule?hl=fr-FR&leagueId=$leagueId',
        planningFormat);

    leagues = fetch(
        'https://esports-api.lolesports.com/persisted/gw/getLeagues?hl=fr-FR',
        liguesFormat);
  }

  dynamic planningFormat(Map res) {
      List<Map<String, dynamic>> events =
          res["data"]["schedule"]["events"].cast<Map<String, dynamic>>();
      leagueSlug = (events.first['league']['slug']).toUpperCase() ?? '';
      return groupEventsByDay(events);
  }

  dynamic liguesFormat(Map res) {
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
      print("fetch failed");
      // throw Exception('${response.statusCode} ${response.body}');
    }
  }

  List<List<Map<String, dynamic>>> groupEventsByDay(
      List<Map<String, dynamic>> events) {
    List<List<Map<String, dynamic>>> groupedEvents = [];

    DateTime? currentDate;
    List<Map<String, dynamic>> currentDayEvents = [];

    for (var event in events) {
      print(event);
      DateTime eventDate = DateTime.parse(event['startTime']);
      if (currentDate == null || eventDate.day != currentDate.day) {
        // Nouveau jour
        if (currentDate != null) {
          groupedEvents.add(List.from(currentDayEvents));
        }
        currentDate = eventDate;
        currentDayEvents = [event];
      } else {
        // Même jour
        currentDayEvents.add(event);
      }
    }

    // Ajouter le dernier jour
    if (currentDate != null) {
      groupedEvents.add(List.from(currentDayEvents));
    }

    return groupedEvents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(221, 54, 53, 53),
        title: Text(
          leagueSlug != null ? '$leagueSlug Planning' : 'Loading...',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(221, 54, 53, 53),
        ),
        child: Center(
          child: FutureBuilder(
            future: planning,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<List<Map<String, dynamic>>> groupedEvents =
                    snapshot.data as List<List<Map<String, dynamic>>>;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: groupedEvents.length,
                    itemBuilder: (context, dayIndex) {
                      List<Map<String, dynamic>> dayEvents =
                          groupedEvents[dayIndex];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Afficher la date du jour
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('EEEE–d MMMM').format(
                                DateTime.parse(dayEvents.first['startTime']),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Afficher les matchs du jour
                          for (var event in dayEvents) ...[
                            Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              elevation: 5.0,
                              color: const Color.fromARGB(221, 54, 53, 53),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left side - Formatted time
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatTime(event['startTime']),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Middle - Team logos and vs
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    80, // Définissez la hauteur souhaitée
                                                child: Image.network(
                                                  event['match']['teams'][0]
                                                      ['image'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Text(
                                                '${event['match']['teams'][0]['name']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (event['state'] == 'completed') ...[
                                          Text(
                                            '${event['match']['teams'][0]['result']['gameWins']} - ${event['match']['teams'][1]['result']['gameWins']}',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ] else ...[
                                          const Text(
                                            'vs',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    80, // Définissez la hauteur souhaitée
                                                child: Image.network(
                                                  event['match']['teams'][1]
                                                      ['image'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Text(
                                                '${event['match']['teams'][1]['name']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Right side - League
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          leagueSlug,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                );
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
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
