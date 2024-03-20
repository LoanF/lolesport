class Schedule {
  List<Event> events;

  Schedule({required this.events});

  Schedule.fromJson(Map<String, dynamic> json)
      : events = (json['events'] as List).map((eventJson) => Event.fromJson(eventJson)).toList();
}

class Event {
  String startTime;
  String state;
  String type;
  String blockName;
  League league;
  Match match;

  Event.fromJson(Map<String, dynamic> json)
      : startTime = json['startTime'],
        state = json['state'],
        type = json['type'],
        blockName = json['blockName'],
        league = League.fromJson(json['league']),
        match = Match.fromJson(json['match']);
}

class League {
  String name;
  String slug;

  League({required this.name, required this.slug});

  League.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        slug = json['slug'];
}

class Match {
  String id;
  List<String> flags;
  List<Team> teams;
  Strategy strategy;

  Match.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        flags = List<String>.from(json['flags'].map((flag) => flag)),
        teams = List<Team>.from(json['teams'].map((team) => Team.fromJson(team))),
        strategy = Strategy.fromJson(json['strategy']);
}

class Team {
  String name;
  String code;
  String image;
  Result result;
  Record? record;

  Team.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        code = json['code'],
        image = json['image'],
        result = Result.fromJson(json['result']),
        record = json['record'] != null ? Record.fromJson(json['record']) : null;
}

class Result {
  String? outcome;
  int? gameWins;

  Result({required this.outcome, required this.gameWins});

  Result.fromJson(Map<String, dynamic>? json)
      : outcome = json?['outcome'],
        gameWins = json?['gameWins'];
}

class Record {
  int? wins;
  int? losses;

  Record({required this.wins, required this.losses});

  Record.fromJson(Map<String, dynamic>? json)
      : wins = json?['wins'],
        losses = json?['losses'];
}

class Strategy {
  String type;
  int count;

  Strategy({required this.type, required this.count});

  Strategy.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        count = json['count'];
}
