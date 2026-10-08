import 'package:flutter/material.dart';
import '../data/match_repository.dart';
import '../data/organizer_auth.dart';
import '../data/player_repository.dart';
import '../data/tournament_logic.dart';
import '../data/tournament_repository.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/standing.dart';
import '../models/tournament.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/xeque_app_bar.dart';

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  final _tournamentRepo = FirestoreTournamentRepository();
  final _playerRepo = FirestorePlayerRepository();
  final _matchRepo = FirestoreMatchRepository();

  // Evita ficar escrevendo no Firestore de novo a cada rebuild.
  bool _autoFinishTriggered = false;
  bool _isDeleting = false;

  /// Se todas as partidas (exceto byes) já têm resultado, o torneio virou
  /// "encerrado" sozinho — o organizador não precisa marcar isso na mão.
  void _maybeAutoFinish(Tournament tournament, List<ChessMatch> matches) {
    if (_autoFinishTriggered) return;
    if (tournament.status == TournamentStatus.finished) return;
    if (matches.isEmpty) return;

    final real = matches.where((m) => !m.isBye).toList();
    if (real.isEmpty) return;
    final allDecided = real.every((m) => m.isDecided);
    if (!allDecided) return;

    _autoFinishTriggered = true;
    _tournamentRepo.updateStatus(tournament.id, TournamentStatus.finished);
  }

  Future<void> _confirmDelete(Tournament tournament) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Excluir "${tournament.name}"?', style: AppTextStyles.cardTitle),
        content: Text(
          'Isso apaga o torneio e todas as suas partidas permanentemente. '
          'Não dá pra desfazer.',
          style: AppTextStyles.cardSubtitle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Excluir',
              style: AppTextStyles.body.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    await _matchRepo.deleteAllForTournament(tournament.id);
    await _tournamentRepo.deleteTournament(tournament.id);

    if (!mounted) return;
    Navigator.of(context).pop(); // volta pra lista de torneios
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: XequeAppBar(title: 'Torneio'),
        body: SafeArea(
          top: false,
          child: StreamBuilder<Tournament?>(
            stream: _tournamentRepo.watchTournament(widget.tournamentId),
            builder: (context, tSnap) {
              if (!tSnap.hasData) {
                return Center(child: CircularProgressIndicator(color: AppColors.accent));
              }
              final tournament = tSnap.data;
              if (tournament == null) {
                return Center(
                  child: Text('Torneio não encontrado.', style: AppTextStyles.cardSubtitle),
                );
              }

              return StreamBuilder<List<Player>>(
                stream: _playerRepo.watchPlayers(),
                builder: (context, pSnap) {
                  final allPlayers = pSnap.data ?? [];
                  final players = allPlayers
                      .where((p) => tournament.playerIds.contains(p.id))
                      .toList();
                  final nameOf = {for (final p in players) p.id: p.name};

                  return StreamBuilder<List<ChessMatch>>(
                    stream: _matchRepo.watchMatches(widget.tournamentId),
                    builder: (context, mSnap) {
                      final matches = mSnap.data ?? [];

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _maybeAutoFinish(tournament, matches);
                      });

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Text(tournament.name, style: AppTextStyles.screenTitle),
                          ),
                          if (tournament.status == TournamentStatus.finished)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: _FinishedBanner(
                                isDeleting: _isDeleting,
                                onDelete: () => _confirmDelete(tournament),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: TabBar(
                              labelColor: AppColors.accent,
                              unselectedLabelColor: AppColors.textMuted,
                              indicatorColor: AppColors.accent,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              tabs: const [
                                Tab(text: 'Rodadas'),
                                Tab(text: 'Classificação'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _RoundsTab(
                                  matches: matches,
                                  nameOf: nameOf,
                                  tournamentId: widget.tournamentId,
                                  players: players,
                                ),
                                _StandingsTab(players: players, matches: matches),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FinishedBanner extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onDelete;

  const _FinishedBanner({required this.isDeleting, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Torneio concluído',
                  style: AppTextStyles.cardTitle.copyWith(color: AppColors.success),
                ),
                Text('Todas as partidas foram decididas.', style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: OrganizerAuth.isOrganizer,
            builder: (context, isOrganizer, _) {
              if (!isOrganizer) return const SizedBox.shrink();
              return isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                      ),
                    )
                  : IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.warning),
                      tooltip: 'Excluir torneio',
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _RoundsTab extends StatelessWidget {
  final List<ChessMatch> matches;
  final Map<String, String> nameOf;
  final String tournamentId;
  final List<Player> players;

  const _RoundsTab({
    required this.matches,
    required this.nameOf,
    required this.tournamentId,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(
        child: Text('Nenhum confronto gerado ainda.', style: AppTextStyles.cardSubtitle),
      );
    }

    final byRound = <int, List<ChessMatch>>{};
    for (final m in matches) {
      byRound.putIfAbsent(m.round, () => []).add(m);
    }
    final rounds = byRound.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        for (final r in rounds) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text('RODADA $r', style: AppTextStyles.sectionLabel),
          ),
          for (final m in byRound[r]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MatchTile(match: m, nameOf: nameOf),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final ChessMatch match;
  final Map<String, String> nameOf;

  const _MatchTile({required this.match, required this.nameOf});

  String _playerName(String? id) {
    if (id == null) return 'Folga';
    return nameOf[id] ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    if (match.isBye) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.free_breakfast_rounded, color: AppColors.textMuted, size: 16),
            const SizedBox(width: 10),
            Text(
              '${_playerName(match.playerAId)} folga nesta rodada',
              style: AppTextStyles.cardSubtitle,
            ),
          ],
        ),
      );
    }

    final aWon = match.result == MatchResult.playerAWin;
    final bWon = match.result == MatchResult.playerBWin;
    final isDraw = match.result == MatchResult.draw;

    return ValueListenableBuilder<bool>(
      valueListenable: OrganizerAuth.isOrganizer,
      builder: (context, isOrganizer, _) {
        return AppCard(
          onTap: isOrganizer ? () => _openResultSheet(context) : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _playerName(match.playerAId),
                  style: AppTextStyles.cardTitle.copyWith(
                    color: aWon ? AppColors.success : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  isDraw ? 'X' : 'vs',
                  style: TextStyle(
                    color: isDraw ? AppColors.accent : AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _playerName(match.playerBId),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: bWon ? AppColors.success : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                match.isDecided ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                size: 16,
                color: match.isDecided ? AppColors.success : AppColors.border,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openResultSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultSheet(match: match, nameOf: nameOf),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final ChessMatch match;
  final Map<String, String> nameOf;

  const _ResultSheet({required this.match, required this.nameOf});

  Future<void> _setResult(BuildContext context, MatchResult result) async {
    await FirestoreMatchRepository().setResult(match.id, result);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final aName = nameOf[match.playerAId] ?? '—';
    final bName = nameOf[match.playerBId] ?? '—';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resultado da partida', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('$aName  vs  $bName', style: AppTextStyles.cardSubtitle),
          const SizedBox(height: 18),
          PrimaryButton(
            label: '$aName venceu',
            icon: Icons.emoji_events_rounded,
            onPressed: () => _setResult(context, MatchResult.playerAWin),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Empate',
            icon: Icons.handshake_rounded,
            color: AppColors.textMuted,
            onPressed: () => _setResult(context, MatchResult.draw),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: '$bName venceu',
            icon: Icons.emoji_events_rounded,
            onPressed: () => _setResult(context, MatchResult.playerBWin),
          ),
        ],
      ),
    );
  }
}

class _StandingsTab extends StatelessWidget {
  final List<Player> players;
  final List<ChessMatch> matches;

  const _StandingsTab({required this.players, required this.matches});

  @override
  Widget build(BuildContext context) {
    final standings = calculateStandings(players: players, matches: matches);

    if (standings.isEmpty) {
      return Center(
        child: Text('Sem jogadores neste torneio.', style: AppTextStyles.cardSubtitle),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: standings.length,
      itemBuilder: (context, i) {
        final s = standings[i];
        final isTop = i == 0 && s.points > 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            borderColor: isTop ? AppColors.accent : AppColors.border,
            backgroundColor: isTop ? AppColors.accentBackground : AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}º',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isTop ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(s.playerName, style: AppTextStyles.cardTitle),
                ),
                Text(
                  '${s.wins}V ${s.draws}E ${s.losses}D',
                  style: AppTextStyles.cardSubtitle,
                ),
                const SizedBox(width: 12),
                Text(
                  s.points % 1 == 0 ? '${s.points.toInt()} pts' : '${s.points} pts',
                  style: TextStyle(
                    color: isTop ? AppColors.accent : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
