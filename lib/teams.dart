import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Teams extends StatefulWidget {
  const Teams({super.key, required this.equipeName});
  final String equipeName;

  @override
  State<Teams> createState() => _EquipeState();
}

class _EquipeState extends State<Teams> {
  late Future equipe;
  late Future event;
  @override
  void initState() {
    super.initState();
    equipe = fetchEquipe(
        'https://esports-api.lolesports.com/persisted/gw/getTeams?hl=fr-FR&id=${widget.equipeName}');
    event = fetchEvent(
        'https://esports-api.lolesports.com/persisted/gw/getEventList?hl=fr-FR&teamId=${widget.equipeName}');
    // Start the simulation when the widget is initialized
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

  Future fetchEvent(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': '0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z',
      },
    );

    if (response.statusCode == 200) {
      Map res = jsonDecode(response.body) as Map<String, dynamic>;
      return res["data"]["esports"]["events"];
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    'https://am-a.akamaihd.net/image?resize=:&f=http%3A%2F%2Fassets.lolesports.com%2Fwatch%2Fteam-header-fallback.jpg'), // Remplacez par l'URL de votre image de fond
                                fit: BoxFit.fill,
                                opacity: 0.4,
                              ),
                            ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        // FutureBuilder(
                        //   future: event,
                        //   builder: (context, eventSnapshot) {
                        //     if (eventSnapshot.hasData) {
                        //       // Par exemple, eventSnapshot.data[0]['nom']
                        //       return Column(
                        //         children: [
                        //           for (Map event in eventSnapshot.data)
                        //             Padding(
                        //                 padding: const EdgeInsets.symmetric(vertical: 4.0),
                        //                 child: Text(
                        //                   event['startTime'],
                        //                   style: const TextStyle(
                        //                     fontSize: 20,
                        //                     color: Colors.white,
                        //                   ),
                        //                 )),
                        //         ],
                        //       );
                        //     } else if (eventSnapshot.hasError) {
                        //       return const Text(
                        //           'Erreur lors du chargement de l\'événement');
                        //     } else {
                        //       return const CircularProgressIndicator();
                        //     }
                        //   },
                        // ),
                        for (Map player in item['players'])
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image(
                                    image: NetworkImage(player['image']),
                                    width: 110,
                                    height: 110,
                                    alignment: Alignment.centerLeft,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          player['firstName'] +
                                              " " +
                                              player['lastName']
                                                  .toString()
                                                  .toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 15, color: Colors.grey),
                                        ),
                                      ],
                                    ),
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
