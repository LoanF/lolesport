import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future lives;
  @override
  void initState() {
    super.initState();
    lives = fetchLive('https://esports-api.lolesports.com/persisted/gw/getLive?hl=fr-FR');
  }

  Future fetchLive(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept-Charset': 'utf-8',
        'x-api-key': dotenv.env['API_KEY']!,
      },
    );

    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      Map res = jsonDecode(responseBody) as Map<String, dynamic>;
      return res["data"]["schedule"]["events"];
    } else {
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 54, 53, 53),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/icon/app_icon.png'),
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Bienvenue sur LolEsport',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text(
                'Explorez les classements, les équipes et les tournois de League of Legends.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              FutureBuilder(
                future: lives,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.length > 0) {
                    int count = snapshot.data.length;
                    return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                          const SizedBox(height: 100),
                          const Text(
                            "Matchs en direct",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
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
                                      decoration: count > 1
                                          ? const BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : null,
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
                        ]));
                  } else if (snapshot.hasError) {
                    return const Text('Error');
                  } else {
                    return const Text('');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
