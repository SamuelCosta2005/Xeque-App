import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament.dart';

abstract class TournamentRepository {
  Stream<List<Tournament>> watchTournaments();
  Stream<Tournament?> watchTournament(String id);
  Future<String> createTournament({required String name, required List<String> playerIds});
  Future<void> updateStatus(String id, TournamentStatus status);
  Future<void> deleteTournament(String id);
}

class FirestoreTournamentRepository implements TournamentRepository {
  final _col = FirebaseFirestore.instance.collection('tournaments');

  @override
  Stream<List<Tournament>> watchTournaments() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => Tournament.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Stream<Tournament?> watchTournament(String id) {
    return _col.doc(id).snapshots().map(
          (doc) => doc.exists ? Tournament.fromMap(doc.id, doc.data()!) : null,
        );
  }

  @override
  Future<String> createTournament({
    required String name,
    required List<String> playerIds,
  }) async {
    final doc = await _col.add(Tournament(
      id: '',
      name: name.trim(),
      playerIds: playerIds,
      status: TournamentStatus.planned,
      createdAt: DateTime.now(),
    ).toMap());
    return doc.id;
  }

  @override
  Future<void> updateStatus(String id, TournamentStatus status) async {
    await _col.doc(id).update({'status': statusToString(status)});
  }

  @override
  Future<void> deleteTournament(String id) async {
    await _col.doc(id).delete();
  }
}
