class ClassementData {
  List<Stage>? standings;
  get standingsData => standings;
}

class Stage {
  String? name;
  List<Section>? sections;
  String? slug;
  get sectionsData => sections;
}

class Section {
  List<Ranking>? rankings;
  String? name;
  get rankingsData => rankings;
}

class Ranking {
  int? ordinal;
  List<Team>? teams;

  get ordinalData => ordinal;
  get teamsData => teams;
}

class Team {
  String? code;
  String? id;
  String? image;
  String? name;
  Record? record;
  String? slug;
  get imageData => image;
  get nameData => name;
  get recordData => record;
}

class Record {
  int? win;
  int? looses;
  get winData => win;
  get loosesData => looses;
}
