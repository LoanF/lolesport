import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lolesport/teams.dart';

class Classement extends StatefulWidget {
  const Classement({Key? key, required this.idLeague}) : super(key: key);

  final String? idLeague;

  @override
  State<Classement> createState() => _ClassementState();
}

class _ClassementState extends State<Classement> {
  String? get idLeague => widget.idLeague;
  List classement = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final classementData = await fetch(
      'https://esports-api.lolesports.com/persisted/gw/getStandingsV3?hl=fr-FR&tournamentId=${await fetch(
        "https://esports-api.lolesports.com/persisted/gw/getTournamentsForLeague?hl=fr-FR&leagueId=${idLeague}",
        tournamentIdFormat,
      )}',
      teamformat,
    );
    setState(() {
      classement = classementData;
    });
  }

  dynamic teamformat(Map res) {
    return res["data"]["standings"][0]["stages"][0]["sections"][0]["rankings"];
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 54, 53, 53),
      body: Center(
        child: classement.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: classement.length,
                  itemBuilder: (context, index) {
                    Map item = classement[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.white),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: item['teams'].length,
                              itemBuilder: (context, teamIndex) {
                                Map team = item['teams'][teamIndex];
                                return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Teams(
                                            equipeName: team['slug'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            child: Text(
                                              item['ordinal'].toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Image.network(
                                            team['image'],
                                            height: 45.0,
                                            width: 45.0,
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${team['name']}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${team["record"]["wins"]} Victoire(s) / ${team["record"]["losses"]} Défaite(s)",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
