import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lolesport/classes/planningData.dart';

class Planning extends StatefulWidget {
  const Planning({Key? key, required this.idLeague}) : super(key: key);

  final String? idLeague;

  @override
  State<Planning> createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  String? get idLeague => widget.idLeague;
  late Schedule schedule = Schedule(events: []);
  late String leagueSlug = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting('fr_FR', null);
    initData();

  }

  void initData() async {
    try {
      final sheduleJsonData = await fetch('https://esports-api.lolesports.com/persisted/gw/getSchedule?hl=fr-FR&leagueId=$idLeague');
      setState(() {
        schedule = Schedule.fromJson(sheduleJsonData['data']['schedule']);
        leagueSlug = schedule.events[0].league.slug.toUpperCase();
      });
    } catch (e) {
      throw 'Error initializing data: $e';
    }
  }

  Future<Map<String, dynamic>> fetch(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept-Charset': 'utf-8',
        'x-api-key': dotenv.env['API_KEY']!,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(221, 54, 53, 53),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: schedule == null
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: schedule.events.length,
                  itemBuilder: (context, index) {
                    // Group events by date
                    Map<String, List<Event>> groupedEvents = {};
                    for (var event in schedule.events) {
                      String formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(
                        DateTime.parse(event.startTime),
                      );
                      groupedEvents.putIfAbsent(formattedDate, () => []);
                      groupedEvents[formattedDate]!.add(event);
                    }

                    // Build list of cards for each group
                    List<Widget> dateCards = [];
                    groupedEvents.forEach((date, events) {
                      // Add date header
                      dateCards.add(
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );

                      // Add event cards for this date
                      for (var event in events) {
                        dateCards.add(buildEventCard(event));
                      }
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: dateCards,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 5.0,
      color: const Color.fromARGB(221, 54, 53, 53),
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
                  _formatTime(event.startTime),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Add other event elements here
              ],
            ),
            // Middle - Team logos and vs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80, // Set the desired height
                        child: Image.network(
                          event.match.teams[0].image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        '${event.match.teams[0].code}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (event.state == 'completed') ...[
                  Text(
                    '${event.match.teams[0].result.gameWins} - ${event.match.teams[1].result.gameWins}',
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
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80, // Set the desired height
                        child: Image.network(
                          event.match.teams[1].image,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        '${event.match.teams[1].code}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    String formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }
}
