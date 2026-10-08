class Player {
  final String id;
  final String name;
  final DateTime createdAt;

  const Player({required this.id, required this.name, required this.createdAt});

  factory Player.fromMap(String id, Map<String, dynamic> map) {
    return Player(
      id: id,
      name: map['name'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };
}
