import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';
import 'tournament_logic.dart';

abstract class MatchRepository {
  Stream<List<ChessMatch>> watchMatches(String tournamentId);
  Future<void> generateRoundRobin(String tournamentId, List<String> playerIds);
  Future<void> setResult(String matchId, MatchResult result);
  Future<void> regeneratePairing(String tournamentId, List<String> playerIds);
  Future<void> deleteAllForTournament(String tournamentId);
}

class FirestoreMatchRepository implements MatchRepository {
  final _col = FirebaseFirestore.instance.collection('matches');

  @override
  Stream<List<ChessMatch>> watchMatches(String tournamentId) {
    return _col
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ChessMatch.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => a.round.compareTo(b.round));
      return list;
    });
  }

  @override
  Future<void> generateRoundRobin(String tournamentId, List<String> playerIds) async {
    final rounds = generateRoundRobinRounds(playerIds);
    final batch = FirebaseFirestore.instance.batch();

    for (var r = 0; r < rounds.length; r++) {
      for (final (a, b) in rounds[r]) {
        final doc = _col.doc();
        final isBye = b == null;
        batch.set(
          doc,
          ChessMatch(
            id: '',
            tournamentId: tournamentId,
            round: r + 1,
            playerAId: a,
            playerBId: b,
            result: isBye ? MatchResult.bye : MatchResult.pending,
          ).toMap(),
        );
      }
    }
    await batch.commit();
  }

  @override
  Future<void> setResult(String matchId, MatchResult result) async {
    await _col.doc(matchId).update({'result': resultToString(result)});
  }

  /// Apaga as partidas pendentes/não jogadas e gera de novo — útil se o
  /// organizador editar a lista de participantes depois de já ter gerado.
  /// Partidas já decididas (com resultado lançado) são preservadas.
  @override
  Future<void> regeneratePairing(String tournamentId, List<String> playerIds) async {
    final existing = await _col.where('tournamentId', isEqualTo: tournamentId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in existing.docs) {
      final m = ChessMatch.fromMap(doc.id, doc.data());
      if (!m.isDecided) batch.delete(doc.reference);
    }
    await batch.commit();
    await generateRoundRobin(tournamentId, playerIds);
  }

  @override
  Future<void> deleteAllForTournament(String tournamentId) async {
    final existing = await _col.where('tournamentId', isEqualTo: tournamentId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
