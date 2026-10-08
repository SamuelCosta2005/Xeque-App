import 'package:flutter/material.dart';
import '../data/organizer_auth.dart';
import '../data/player_repository.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/xeque_app_bar.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final PlayerRepository _repo = FirestorePlayerRepository();
  final _nameController = TextEditingController();

  Future<void> _addPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await _repo.addPlayer(name);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XequeAppBar(title: 'XEQUE'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text('Jogadores', style: AppTextStyles.screenTitle),
            ),
            Expanded(
              child: StreamBuilder<List<Player>>(
                stream: _repo.watchPlayers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }
                  final players = snapshot.data!;
                  if (players.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum jogador cadastrado ainda.',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: players.length,
                    itemBuilder: (context, i) {
                      final p = players[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.accent,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(p.name, style: AppTextStyles.cardTitle),
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: OrganizerAuth.isOrganizer,
                                builder: (context, isOrganizer, _) {
                                  if (!isOrganizer) return const SizedBox.shrink();
                                  return IconButton(
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.warning,
                                      size: 19,
                                    ),
                                    onPressed: () => _repo.deletePlayer(p.id),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: OrganizerAuth.isOrganizer,
              builder: (context, isOrganizer, _) {
                if (!isOrganizer) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _nameController,
                            onSubmitted: (_) => _addPlayer(),
                            style: AppTextStyles.body,
                            cursorColor: AppColors.accent,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nome do novo jogador',
                              hintStyle: AppTextStyles.cardSubtitle,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _addPlayer,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.add_rounded,
                              color: AppColors.background,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
