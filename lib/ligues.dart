import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Ligues extends StatefulWidget {
  const Ligues({Key? key}) : super(key: key);

  @override
  State<Ligues> createState() => _LiguesState();
}

class _LiguesState extends State<Ligues> {
  late Future ligues;

  @override
  void initState() {
    super.initState();
    ligues = fetch(
        'https://esports-api.lolesports.com/persisted/gw/getLeagues?hl=fr-FR',
        liguesFormat);
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
      throw Exception('${response.statusCode} ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 54, 53, 53),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 54, 53, 53),
        foregroundColor: Colors.white,
        title: const Text("Toutes ligues"),
      ),
      body: Center(
        child: FutureBuilder(
          future: ligues,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data.isEmpty) {
              return const Text('Aucune donnée disponible.');
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Map ligue = snapshot.data[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/classement',
                            arguments: {'ligueId': ligue['id']});
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(bottom: 10),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                ligue['image'],
                                height: 50.0,
                                width: 50.0,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ligue['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ligue['region'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
