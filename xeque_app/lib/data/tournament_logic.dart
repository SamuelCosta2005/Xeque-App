import '../models/match.dart';
import '../models/player.dart';
import '../models/standing.dart';

/// Gera as rodadas de um torneio todos-contra-todos (round-robin) usando o
/// método do círculo: fixa o primeiro jogador e gira os demais a cada
/// rodada. Se o número de jogadores for ímpar, usa `null` como um jogador
/// fantasma — quem cai contra ele folga a rodada (bye).
///
/// Retorna uma lista de rodadas; cada rodada é uma lista de pares
/// (playerAId, playerBId?) já prontos pra virar [ChessMatch].
List<List<(String, String?)>> generateRoundRobinRounds(List<String> playerIds) {
  final ids = List<String?>.from(playerIds);
  if (ids.length < 2) return [];
  if (ids.length.isOdd) ids.add(null); // folga/bye

  final n = ids.length;
  final roundsCount = n - 1;
  final rounds = <List<(String, String?)>>[];

  var current = List<String?>.from(ids);

  for (var r = 0; r < roundsCount; r++) {
    final roundPairs = <(String, String?)>[];
    for (var i = 0; i < n ~/ 2; i++) {
      final a = current[i];
      final b = current[n - 1 - i];
      // Só registra o par se pelo menos um dos dois for jogador de verdade.
      if (a != null || b != null) {
        // Garante que o jogador "de verdade" fique sempre em playerA quando
        // o outro for bye (null), pra facilitar a leitura em tela.
        if (a != null) {
          roundPairs.add((a, b));
        } else {
          roundPairs.add((b!, null));
        }
      }
    }
    rounds.add(roundPairs);

    // Rotação do método do círculo: posição 0 fixa, o resto gira.
    final fixed = current[0];
    final rest = current.sublist(1);
    final rotated = [rest.last, ...rest.sublist(0, rest.length - 1)];
    current = [fixed, ...rotated];
  }

  return rounds;
}

/// Calcula a classificação (pontos, V/E/D) de um torneio a partir das
/// partidas já decididas. Vitória = 1pt, empate = 0,5pt, derrota = 0pt.
List<Standing> calculateStandings({
  required List<Player> players,
  required List<ChessMatch> matches,
}) {
  final byId = {for (final p in players) p.id: p};
  final standings = {
    for (final p in players) p.id: Standing(playerId: p.id, playerName: p.name),
  };

  for (final m in matches) {
    if (m.isBye || !byId.containsKey(m.playerAId)) continue;
    final a = standings[m.playerAId];
    final b = m.playerBId != null ? standings[m.playerBId] : null;
    if (a == null) continue;

    switch (m.result) {
      case MatchResult.playerAWin:
        a.points += 1;
        a.wins += 1;
        a.played += 1;
        if (b != null) {
          b.losses += 1;
          b.played += 1;
        }
        break;
      case MatchResult.playerBWin:
        if (b != null) {
          b.points += 1;
          b.wins += 1;
          b.played += 1;
        }
        a.losses += 1;
        a.played += 1;
        break;
      case MatchResult.draw:
        a.points += 0.5;
        a.draws += 1;
        a.played += 1;
        if (b != null) {
          b.points += 0.5;
          b.draws += 1;
          b.played += 1;
        }
        break;
      case MatchResult.pending:
      case MatchResult.bye:
        break;
    }
  }

  final list = standings.values.toList();
  list.sort((x, y) {
    final byPoints = y.points.compareTo(x.points);
    if (byPoints != 0) return byPoints;
    return y.wins.compareTo(x.wins); // desempate simples: mais vitórias
  });
  return list;
}
