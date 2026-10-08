/// Resultado de uma partida. [pending] = ainda não jogada/declarada.
enum MatchResult { pending, playerAWin, playerBWin, draw, bye }

MatchResult resultFromString(String? v) {
  switch (v) {
    case 'playerAWin':
      return MatchResult.playerAWin;
    case 'playerBWin':
      return MatchResult.playerBWin;
    case 'draw':
      return MatchResult.draw;
    case 'bye':
      return MatchResult.bye;
    default:
      return MatchResult.pending;
  }
}

String resultToString(MatchResult r) => r.name;

class ChessMatch {
  final String id;
  final String tournamentId;
  final int round;
  final String playerAId;
  final String? playerBId; // null = bye (playerA folga essa rodada)
  final MatchResult result;

  const ChessMatch({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.playerAId,
    required this.playerBId,
    required this.result,
  });

  bool get isBye => playerBId == null;
  bool get isDecided => result != MatchResult.pending;

  factory ChessMatch.fromMap(String id, Map<String, dynamic> map) {
    return ChessMatch(
      id: id,
      tournamentId: map['tournamentId'] as String? ?? '',
      round: (map['round'] as num?)?.toInt() ?? 1,
      playerAId: map['playerAId'] as String? ?? '',
      playerBId: map['playerBId'] as String?,
      result: resultFromString(map['result'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        'tournamentId': tournamentId,
        'round': round,
        'playerAId': playerAId,
        'playerBId': playerBId,
        'result': resultToString(result),
      };

  ChessMatch copyWith({MatchResult? result}) => ChessMatch(
        id: id,
        tournamentId: tournamentId,
        round: round,
        playerAId: playerAId,
        playerBId: playerBId,
        result: result ?? this.result,
      );
}
