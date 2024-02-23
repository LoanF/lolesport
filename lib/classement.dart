import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Classement extends StatefulWidget {
  const Classement({super.key});

  @override
  State<Classement> createState() => _ClassementState();
}

class _ClassementState extends State<Classement> {
  late Future classement;
  late Future ligue;
  late Future tournamentId;
  late Map args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{})
        as Map;

    // Now you can use args in your asynchronous calls or other initialization logic
    _fetchData();
  }

  Future<void> _fetchData() async {
    ligue = fetch(
        'https://esports-api.lolesports.com/persisted/gw/getLeagues?hl=fr-FR&id=${args['ligueId']}',
        ligueFormat);
    tournamentId = await fetch(
        "https://esports-api.lolesports.com/persisted/gw/getTournamentsForLeague?hl=fr-FR&leagueId=${args['ligueId']}",
        tournamentIdFormat);

    classement = await fetch(
        'https://esports-api.lolesports.com/persisted/gw/getStandingsV3?hl=fr-FR&tournamentId=${tournamentId}',
        teamformat);
  }

  dynamic teamformat(Map res) {
    return res["data"]["standings"][0]["stages"][0]["sections"][0]["rankings"];
  }

  dynamic ligueFormat(Map res) {
    return res["data"]["leagues"];
  }

  dynamic tournamentIdFormat(Map res) {
    return res["data"]["leagues"][0]["tournaments"][0]["id"];
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

  @override
  Widget build(BuildContext context) {
    if (classement == null) {
      // Handle the case where classement is not initialized yet
      return const CircularProgressIndicator();
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 54, 53, 53),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 54, 53, 53),
        foregroundColor: Colors.white,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FutureBuilder(
            future: ligue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 10),
                    Title(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data[0]['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            snapshot.data[0]['region'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 70),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator.adaptive();
            },
          ),
        ]),
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
                        for (Map team in item['teams'])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: ListBody(children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(bottom: 10),
                                decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(color: Colors.white)),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Text(
                                        item['ordinal'].toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Image.network(team['image'],
                                        height: 50.0, width: 50.0),
                                    const SizedBox(
                                        width:
                                            10), // Add some spacing between image and text
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${team['name']}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${team["record"]["wins"]} Victoire(s) / ${team["record"]["losses"]} Défaite(s)",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ]),
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
    );
  }
}
