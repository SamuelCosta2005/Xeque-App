import 'package:flutter/material.dart';
import '../data/match_repository.dart';
import '../data/player_repository.dart';
import '../data/tournament_repository.dart';
import '../models/player.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_label.dart';
import '../widgets/xeque_app_bar.dart';
import 'tournament_detail_screen.dart';

class NewTournamentScreen extends StatefulWidget {
  const NewTournamentScreen({super.key});

  @override
  State<NewTournamentScreen> createState() => _NewTournamentScreenState();
}

class _NewTournamentScreenState extends State<NewTournamentScreen> {
  final _nameController = TextEditingController();
  final _playerRepo = FirestorePlayerRepository();
  final _tournamentRepo = FirestoreTournamentRepository();
  final _matchRepo = FirestoreMatchRepository();

  final Set<String> _selected = {};
  bool _isCreating = false;

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selected.length < 2 || _isCreating) return;

    setState(() => _isCreating = true);
    final playerIds = _selected.toList();
    final tournamentId = await _tournamentRepo.createTournament(
      name: name,
      playerIds: playerIds,
    );
    await _matchRepo.generateRoundRobin(tournamentId, playerIds);

    if (!mounted) return;
    setState(() => _isCreating = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TournamentDetailScreen(tournamentId: tournamentId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _nameController.text.trim().isNotEmpty && _selected.length >= 2;

    return Scaffold(
      appBar: XequeAppBar(title: 'Novo Torneio'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  SectionLabel('Nome do torneio'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.body,
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ex: Torneio de Outubro',
                        hintStyle: AppTextStyles.cardSubtitle,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SectionLabel('Participantes'),
                      const SizedBox(width: 6),
                      Text('(mín. 2)', style: AppTextStyles.cardSubtitle),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Se o número for ímpar, alguém folga por rodada automaticamente.',
                    style: AppTextStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<List<Player>>(
                    stream: _playerRepo.watchPlayers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.accent),
                          ),
                        );
                      }
                      final players = snapshot.data!;
                      if (players.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Cadastre jogadores na aba "Jogadores" primeiro.',
                            style: AppTextStyles.cardSubtitle,
                          ),
                        );
                      }
                      return Column(
                        children: players.map((p) {
                          final selected = _selected.contains(p.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              onTap: () => setState(() {
                                selected ? _selected.remove(p.id) : _selected.add(p.id);
                              }),
                              borderColor: selected ? AppColors.accent : AppColors.border,
                              backgroundColor:
                                  selected ? AppColors.accentBackground : AppColors.surface,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text(p.name, style: AppTextStyles.cardTitle)),
                                  Icon(
                                    selected
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    color: selected ? AppColors.accent : AppColors.border,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: PrimaryButton(
                label: 'Gerar Confrontos',
                icon: Icons.auto_awesome_rounded,
                isLoading: _isCreating,
                onPressed: canCreate ? _create : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
