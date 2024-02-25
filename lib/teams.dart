import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Teams extends StatefulWidget {
  const Teams({super.key, required this.equipeName});
  final String equipeName;

  @override
  State<Teams> createState() => _EquipeState();
}

class _EquipeState extends State<Teams> {
  late Future equipe;
  late Future lives;
  @override
  void initState() {
    super.initState();
    if (widget.equipeName.isEmpty) {
      throw ArgumentError('Vous devez spécifier le nom de l\'équipe');
    }
    equipe = fetchEquipe('https://esports-api.lolesports.com/persisted/gw/getTeams?hl=fr-FR&id=${widget.equipeName}');
    lives = fetchLive('https://esports-api.lolesports.com/persisted/gw/getLive?hl=fr-FR');
  }

  Future fetchEquipe(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',
      },
    );

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body) as Map<String, dynamic>;
      return res["data"]["teams"];
    } else {
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  Future fetchLive(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',
      },
    );

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body) as Map<String, dynamic>;
      return res["data"]["schedule"]["events"];
    } else {
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: equipe,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data[0]['name']);
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return const Text('Chargement...');
            }
          },
        ),
        backgroundColor: const Color.fromARGB(221, 54, 53, 53),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: FutureBuilder(
          future: equipe,
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image(
                                  image: NetworkImage(item['image']),
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.centerLeft,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${item['name']}",
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "${item['homeLeague']['name']} - ${item['homeLeague']['region']}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: lives,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (Map live in snapshot.data)
                                      GestureDetector(
                                        onTap: () async {
                                          if (live['state'] == 'completed') {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Le match est terminé"),
                                              ),
                                            );
                                            return;
                                          }

                                          Uri url = Uri();
                                          if (live['streams'][0]['provider'] == 'twitch') {
                                            url = Uri.parse("https://twitch.tv/${live['streams'][0]['parameter']}");
                                          } else if (live['streams'][0]['provider'] == 'youtube') {
                                            url = Uri.parse("https://youtube.com/watch?v=${live['streams'][0]['parameter']}");
                                          } else {
                                            return;
                                          }

                                          if (await launchUrl(url) == false) {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                live['state'] == 'inProgress' || live['state'] == 'completed'
                                                    ? const Row(
                                                        children: [
                                                          Icon(Icons.circle, size: 12, color: Colors.red),
                                                          SizedBox(width: 5),
                                                          Text(
                                                            "En direct",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.green,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        "Date et heure: ${live['match']['date']} ${live['match']['time']}",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    live['match'] != null
                                                        ? Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    "${live['match']['teams'][0]['code']}",
                                                                    style: const TextStyle(
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(width: 10),
                                                                  Image(
                                                                    image: NetworkImage(
                                                                      live['match']['teams'][0]['image'],
                                                                    ),
                                                                    width: 20,
                                                                    height: 20,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        : Image(
                                                            image: NetworkImage(
                                                              live['league']['image'], // Remplacez par le chemin du logo de la ligue
                                                            ),
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                    live['match'] != null ? const SizedBox(width: 10) : const SizedBox(),
                                                    live['match'] != null
                                                        ? const Text(
                                                            "vs",
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white54,
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                    live['match'] != null ? const SizedBox(width: 10) : const SizedBox(),
                                                    live['match'] != null
                                                        ? Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Image(
                                                                    image: NetworkImage(
                                                                      live['match']['teams'][1]['image'],
                                                                    ),
                                                                    width: 20,
                                                                    height: 20,
                                                                  ),
                                                                  const SizedBox(width: 10),
                                                                  Text(
                                                                    "${live['match']['teams'][1]['code']}",
                                                                    style: const TextStyle(
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        : const SizedBox(), // Si pas de match, ne rien afficher ici
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Text(
                                                    live['league']['name'],
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Text('Error');
                            } else {
                              return const Text('Chargement...');
                            }
                          },
                        ),
                        for (Map player in item['players'])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          "assets/img/${player['role']}.png",
                                          width: 50,
                                          height: 50,
                                        ),
                                        Text(
                                          player['summonerName'],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          player['firstName'] + " " + player['lastName'].toString().toUpperCase(),
                                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Image(
                                    image: NetworkImage(player['image']),
                                    width: 120,
                                    height: 110,
                                    alignment: Alignment.centerLeft,
                                  ),
                                ],
                              ),
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
            return const CircularProgressIndicator();
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(221, 54, 53, 53),
    );
  }
}
