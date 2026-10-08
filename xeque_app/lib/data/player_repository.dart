import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

abstract class PlayerRepository {
  Stream<List<Player>> watchPlayers();
  Future<void> addPlayer(String name);
  Future<void> deletePlayer(String id);
}

class FirestorePlayerRepository implements PlayerRepository {
  final _col = FirebaseFirestore.instance.collection('players');

  @override
  Stream<List<Player>> watchPlayers() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => Player.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> addPlayer(String name) async {
    await _col.add(Player(
      id: '',
      name: name.trim(),
      createdAt: DateTime.now(),
    ).toMap());
  }

  @override
  Future<void> deletePlayer(String id) async {
    await _col.doc(id).delete();
  }
}
