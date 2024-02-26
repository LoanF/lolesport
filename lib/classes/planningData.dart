class Schedule {
  List<Event> events;

  Schedule({required this.events});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      events: List<Event>.from(json['events'].map((event) => Event.fromJson(event))),
    );
  }
}

class Event {
  String startTime;
  String state;
  String type;
  String blockName;
  League league;
  Match match;

  Event({
    required this.startTime,
    required this.state,
    required this.type,
    required this.blockName,
    required this.league,
    required this.match,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      startTime: json['startTime'],
      state: json['state'],
      type: json['type'],
      blockName: json['blockName'],
      league: League.fromJson(json['league']),
      match: Match.fromJson(json['match']),
    );
  }
}

class League {
  String name;
  String slug;

  League({required this.name, required this.slug});

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      name: json['name'],
      slug: json['slug'],
    );
  }
}

class Match {
  String id;
  List<String> flags;
  List<Team> teams;
  Strategy strategy;

  Match({
    required this.id,
    required this.flags,
    required this.teams,
    required this.strategy,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      flags: List<String>.from(json['flags'].map((flag) => flag)),
      teams: List<Team>.from(json['teams'].map((team) => Team.fromJson(team))),
      strategy: Strategy.fromJson(json['strategy']),
    );
  }
}

class Team {
  String name;
  String code;
  String image;
  Result result;
  Record record;

  Team({
    required this.name,
    required this.code,
    required this.image,
    required this.result,
    required this.record,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      name: json['name'],
      code: json['code'],
      image: json['image'],
      result: Result.fromJson(json['result']),
      record: Record.fromJson(json['record']),
    );
  }
}

class Result {
  String ?outcome;
  int ?gameWins;

  Result({required this.outcome, required this.gameWins});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      outcome: json['outcome'],
      gameWins: json['gameWins'],
    );
  }
}

class Record {
  int wins;
  int losses;

  Record({required this.wins, required this.losses});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      wins: json['wins'],
      losses: json['losses'],
    );
  }
}

class Strategy {
  String type;
  int count;

  Strategy({required this.type, required this.count});

  factory Strategy.fromJson(Map<String, dynamic> json) {
    return Strategy(
      type: json['type'],
      count: json['count'],
    );
  }
}
