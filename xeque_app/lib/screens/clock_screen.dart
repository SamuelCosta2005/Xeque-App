import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_label.dart';
import '../widgets/xeque_app_bar.dart';

/// Relógio de xadrez de dois lados — aberto pra qualquer pessoa que abrir o
/// app usar (não precisa de PIN de organizador, é só uma ferramenta local,
/// não mexe no banco de dados).
class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

enum _Side { top, bottom }

class _ClockScreenState extends State<ClockScreen> {
  static const List<int> _presets = [3, 5, 10, 15, 30];

  // Modo de configuração: predefinido (botões) ou livre (campos digitados).
  bool _customMode = false;
  int _selectedMinutes = 10;

  final _customP1Controller = TextEditingController(text: '10');
  final _customP2Controller = TextEditingController(text: '10');
  final _incrementController = TextEditingController(text: '0');
  String? _customError;

  bool _started = false;
  bool _running = false;
  _Side? _activeSide;
  late int _topSeconds;
  late int _bottomSeconds;
  int _incrementSeconds = 0;
  _Side? _timedOutSide;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _topSeconds = _selectedMinutes * 60;
    _bottomSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _customP1Controller.dispose();
    _customP2Controller.dispose();
    _incrementController.dispose();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeSide == null || !_running) return;
      setState(() {
        if (_activeSide == _Side.top) {
          _topSeconds = math.max(0, _topSeconds - 1);
          if (_topSeconds == 0) _onTimeOut(_Side.top);
        } else {
          _bottomSeconds = math.max(0, _bottomSeconds - 1);
          if (_bottomSeconds == 0) _onTimeOut(_Side.bottom);
        }
      });
    });
  }

  void _onTimeOut(_Side side) {
    _running = false;
    _timedOutSide = side;
  }

  /// Toca no lado que ACABOU de jogar — isso para o relógio de quem tocou
  /// e passa a contagem pro outro lado (igual um relógio físico de verdade).
  void _onTapSide(_Side tapped) {
    if (_timedOutSide != null) return;

    if (_activeSide == null) {
      // Primeiro toque da partida: quem tocou acabou de jogar, o OUTRO lado
      // começa a contar (igual um relógio físico de verdade).
      setState(() {
        _running = true;
        _activeSide = tapped == _Side.top ? _Side.bottom : _Side.top;
      });
      _startTicker();
      return;
    }

    if (_activeSide != tapped) return; // só o lado ativo pode "passar a vez"
    setState(() {
      // Acréscimo (incremento tipo Fischer): soma pro lado que ACABOU de
      // jogar, antes de passar a vez — é assim que relógio de torneio funciona.
      if (_incrementSeconds > 0) {
        if (tapped == _Side.top) {
          _topSeconds += _incrementSeconds;
        } else {
          _bottomSeconds += _incrementSeconds;
        }
      }
      _activeSide = tapped == _Side.top ? _Side.bottom : _Side.top;
    });
  }

  void _togglePause() {
    if (!_started || _timedOutSide != null) return;
    setState(() => _running = !_running);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _started = false;
      _running = false;
      _activeSide = null;
      _timedOutSide = null;
      // Volta pra tela de configuração com os mesmos campos preenchidos
      // (presets ou modo livre), só reseta o relógio em si.
    });
  }

  /// Lê os campos do modo livre. Retorna null (e seta _customError) se
  /// algum valor for inválido.
  (int p1Min, int p2Min, int incSec)? _readCustomValues() {
    final p1 = int.tryParse(_customP1Controller.text.trim());
    final p2 = int.tryParse(_customP2Controller.text.trim());
    final inc = int.tryParse(_incrementController.text.trim());

    if (p1 == null || p1 <= 0 || p2 == null || p2 <= 0) {
      setState(() => _customError = 'Digite um tempo válido (em minutos) pros dois jogadores.');
      return null;
    }
    if (inc == null || inc < 0) {
      setState(() => _customError = 'O acréscimo não pode ser negativo (pode ser 0).');
      return null;
    }
    setState(() => _customError = null);
    return (p1, p2, inc);
  }

  void _start() {
    int p1Minutes;
    int p2Minutes;
    int incSeconds;

    if (_customMode) {
      final values = _readCustomValues();
      if (values == null) return; // erro já mostrado no campo
      (p1Minutes, p2Minutes, incSeconds) = values;
    } else {
      p1Minutes = _selectedMinutes;
      p2Minutes = _selectedMinutes;
      incSeconds = 0;
    }

    setState(() {
      _bottomSeconds = p1Minutes * 60; // Jogador 1 = lado de baixo
      _topSeconds = p2Minutes * 60; // Jogador 2 = lado de cima
      _incrementSeconds = incSeconds;
      _started = true;
    });
  }

  String _format(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XequeAppBar(title: 'Relógio'),
      body: SafeArea(
        top: false,
        child: _started ? _buildClockFace() : _buildSetup(),
      ),
    );
  }

  Widget _buildSetup() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        Text('Relógio de Xadrez', style: AppTextStyles.screenTitle),
        const SizedBox(height: 6),
        Text(
          'Escolha o tempo e toque em "Começar". Depois, cada jogador toca '
          'no próprio lado assim que termina a jogada.',
          style: AppTextStyles.screenSubtitle,
        ),
        const SizedBox(height: 20),

        // Seletor: Rápido (botões prontos) ou Livre (você digita).
        Row(
          children: [
            Expanded(
              child: _ModeTab(
                label: 'Rápido',
                selected: !_customMode,
                onTap: () => setState(() => _customMode = false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ModeTab(
                label: 'Livre',
                selected: _customMode,
                onTap: () => setState(() => _customMode = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (!_customMode) ...[
          SectionLabel('Tempo por jogador'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presets.map((min) {
              final selected = min == _selectedMinutes;
              return GestureDetector(
                onTap: () => setState(() => _selectedMinutes = min),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accentBackground : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$min min',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: selected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          SectionLabel('Tempo e acréscimo personalizados'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  label: 'Jogador 1 (min)',
                  controller: _customP1Controller,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NumberField(
                  label: 'Jogador 2 (min)',
                  controller: _customP2Controller,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _NumberField(
            label: 'Acréscimo por jogada (segundos)',
            controller: _incrementController,
          ),
          if (_customError != null) ...[
            const SizedBox(height: 8),
            Text(
              _customError!,
              style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.warning),
            ),
          ],
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Acréscimo é o tempo que soma pro relógio de quem jogou, logo '
              'depois de cada jogada (tipo incremento Fischer). Deixe 0 pra '
              'não ter acréscimo.',
              style: AppTextStyles.cardSubtitle,
            ),
          ),
        ],

        const SizedBox(height: 24),
        AppCard(
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dica: deite o celular na mesa entre os dois jogadores. O lado '
                  'de cima fica de cabeça pra baixo de propósito, pra ficar de '
                  'frente pra quem está sentado daquele lado.',
                  style: AppTextStyles.cardSubtitle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Começar',
          icon: Icons.play_arrow_rounded,
          onPressed: _start,
        ),
      ],
    );
  }

  Widget _buildClockFace() {
    return Column(
      children: [
        Expanded(
          child: Transform.rotate(
            angle: math.pi,
            child: _ClockHalf(
              label: 'Jogador 2',
              seconds: _topSeconds,
              totalSeconds: _selectedMinutes * 60,
              isActive: _activeSide == _Side.top && _running,
              isTimedOut: _timedOutSide == _Side.top,
              formattedTime: _format(_topSeconds),
              onTap: () => _onTapSide(_Side.top),
            ),
          ),
        ),
        _ControlBar(
          running: _running,
          onPauseResume: _togglePause,
          onReset: _reset,
        ),
        Expanded(
          child: _ClockHalf(
            label: 'Jogador 1',
            seconds: _bottomSeconds,
            totalSeconds: _selectedMinutes * 60,
            isActive: _activeSide == _Side.bottom && _running,
            isTimedOut: _timedOutSide == _Side.bottom,
            formattedTime: _format(_bottomSeconds),
            onTap: () => _onTapSide(_Side.bottom),
          ),
        ),
      ],
    );
  }
}

class _ClockHalf extends StatelessWidget {
  final String label;
  final int seconds;
  final int totalSeconds;
  final bool isActive;
  final bool isTimedOut;
  final String formattedTime;
  final VoidCallback onTap;

  const _ClockHalf({
    required this.label,
    required this.seconds,
    required this.totalSeconds,
    required this.isActive,
    required this.isTimedOut,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lowTime = seconds <= 30 && seconds > 0;

    Color bg;
    Color fg;
    if (isTimedOut) {
      bg = AppColors.warningBackground;
      fg = AppColors.warning;
    } else if (isActive) {
      bg = AppColors.accentBackground;
      fg = AppColors.accent;
    } else {
      bg = AppColors.surface;
      fg = AppColors.textSecondary;
    }
    if (lowTime && isActive) fg = AppColors.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: bg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isTimedOut ? '$label — sem tempo' : label,
              style: AppTextStyles.sectionLabel.copyWith(color: fg),
            ),
            const SizedBox(height: 8),
            Text(
              formattedTime,
              style: TextStyle(
                color: fg,
                fontSize: 52,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 6),
              Text('toque ao terminar a jogada', style: AppTextStyles.cardSubtitle.copyWith(color: fg)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  final bool running;
  final VoidCallback onPauseResume;
  final VoidCallback onReset;

  const _ControlBar({
    required this.running,
    required this.onPauseResume,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleIconButton(
            icon: running ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: onPauseResume,
          ),
          const SizedBox(width: 16),
          _CircleIconButton(icon: Icons.refresh_rounded, onTap: onReset),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

/// Aba "Rápido" / "Livre" no topo da configuração do relógio.
class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBackground : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.cardTitle.copyWith(
            color: selected ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Campo numérico usado no modo livre (minutos de cada jogador, acréscimo).
class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _NumberField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.cardSubtitle),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(),
            style: AppTextStyles.body,
            cursorColor: AppColors.accent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
