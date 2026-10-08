enum TournamentStatus { planned, ongoing, finished }

TournamentStatus statusFromString(String? v) {
  switch (v) {
    case 'ongoing':
      return TournamentStatus.ongoing;
    case 'finished':
      return TournamentStatus.finished;
    default:
      return TournamentStatus.planned;
  }
}

String statusToString(TournamentStatus s) => s.name;

class Tournament {
  final String id;
  final String name;
  final List<String> playerIds;
  final TournamentStatus status;
  final DateTime createdAt;

  const Tournament({
    required this.id,
    required this.name,
    required this.playerIds,
    required this.status,
    required this.createdAt,
  });

  factory Tournament.fromMap(String id, Map<String, dynamic> map) {
    return Tournament(
      id: id,
      name: map['name'] as String? ?? '',
      playerIds: List<String>.from(map['playerIds'] as List? ?? []),
      status: statusFromString(map['status'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'playerIds': playerIds,
        'status': statusToString(status),
        'createdAt': createdAt.toIso8601String(),
      };

  Tournament copyWith({TournamentStatus? status}) => Tournament(
        id: id,
        name: name,
        playerIds: playerIds,
        status: status ?? this.status,
        createdAt: createdAt,
      );
}
