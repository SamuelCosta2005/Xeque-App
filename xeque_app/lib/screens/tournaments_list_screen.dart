import 'package:flutter/material.dart';
import '../data/organizer_auth.dart';
import '../data/tournament_repository.dart';
import '../models/tournament.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/xeque_app_bar.dart';
import 'new_tournament_screen.dart';
import 'tournament_detail_screen.dart';

class TournamentsListScreen extends StatelessWidget {
  const TournamentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = FirestoreTournamentRepository();

    return Scaffold(
      appBar: XequeAppBar(title: 'XEQUE'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Torneios', style: AppTextStyles.screenTitle)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Tournament>>(
                stream: repo.watchTournaments(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }
                  final tournaments = snapshot.data!;
                  if (tournaments.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum torneio criado ainda.',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    itemCount: tournaments.length,
                    itemBuilder: (context, i) {
                      final t = tournaments[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TournamentTile(tournament: t),
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
                  child: PrimaryButton(
                    label: 'Novo Torneio',
                    icon: Icons.add_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => NewTournamentScreen()),
                      );
                    },
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

class _TournamentTile extends StatelessWidget {
  final Tournament tournament;
  const _TournamentTile({required this.tournament});

  (String, Color, Color) get _statusVisual {
    switch (tournament.status) {
      case TournamentStatus.planned:
        return ('A COMEÇAR', AppColors.textMuted, AppColors.surfaceAlt);
      case TournamentStatus.ongoing:
        return ('EM ANDAMENTO', AppColors.accent, AppColors.accentBackground);
      case TournamentStatus.finished:
        return ('ENCERRADO', AppColors.success, AppColors.successBackground);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = _statusVisual;

    return AppCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TournamentDetailScreen(tournamentId: tournament.id)),
        );
      },
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tournament.name, style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                Text(
                  '${tournament.playerIds.length} jogadores',
                  style: AppTextStyles.cardSubtitle,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
