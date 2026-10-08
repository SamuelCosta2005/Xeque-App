import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'clock_screen.dart';
import 'players_screen.dart';
import 'tournaments_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Sem `const` aqui de propósito: essas telas leem AppColors por dentro,
    // e widgets const "congelam" na cor de quando foram montados pela
    // primeira vez, ignorando trocas de tema depois (mesmo bug corrigido
    // no Hermes). Ver histórico do projeto se quiser entender a fundo.
    final pages = [
      TournamentsListScreen(),
      PlayersScreen(),
      ClockScreen(),
    ];

    return Scaffold(
      // IndexedStack (em vez de só trocar o widget) mantém as 3 abas
      // montadas o tempo todo — importante pro relógio: se o jogador for
      // olhar outra aba no meio da partida, a contagem continua rodando
      // em vez de resetar.
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Torneios',
                  selected: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: Icons.groups_rounded,
                  label: 'Jogadores',
                  selected: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  icon: Icons.timer_rounded,
                  label: 'Relógio',
                  selected: _index == 2,
                  onTap: () => setState(() => _index = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
