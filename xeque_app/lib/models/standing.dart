class Standing {
  final String playerId;
  final String playerName;
  double points;
  int wins;
  int draws;
  int losses;
  int played;

  Standing({
    required this.playerId,
    required this.playerName,
    this.points = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.played = 0,
  });
}
