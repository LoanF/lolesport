import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  @override
  void initState() {
    super.initState();
    if (widget.equipeName.isEmpty) {
      throw ArgumentError('Vous devez spécifier le nom de l\'équipe');
    }
    equipe = fetchEquipe('https://esports-api.lolesports.com/persisted/gw/getTeams?hl=fr-FR&id=${widget.equipeName}');
  }

  Future fetchEquipe(String url) async {
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
      return res["data"]["teams"];
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
