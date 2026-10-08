import 'package:flutter/material.dart';
import '../data/organizer_auth.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';

/// Ícone de cadeado na app bar. Mostra se o modo organizador está ativo
/// e, ao tocar, abre o diálogo de PIN (ou sai do modo, se já estiver dentro).
class OrganizerLockButton extends StatelessWidget {
  const OrganizerLockButton({super.key});

  Future<void> _onTap(BuildContext context) async {
    if (OrganizerAuth.isOrganizer.value) {
      OrganizerAuth.lock();
      return;
    }
    await showDialog<void>(context: context, builder: (_) => const _PinDialog());
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: OrganizerAuth.isOrganizer,
      builder: (context, isOrganizer, _) {
        return GestureDetector(
          onTap: () => _onTap(context),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOrganizer ? AppColors.accentBackground : AppColors.surfaceAlt,
              border: Border.all(
                color: isOrganizer ? AppColors.accent : AppColors.border,
              ),
            ),
            child: Icon(
              isOrganizer ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: isOrganizer ? AppColors.accent : AppColors.textSecondary,
              size: 17,
            ),
          ),
        );
      },
    );
  }
}

class _PinDialog extends StatefulWidget {
  const _PinDialog();

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _submit() {
    final ok = OrganizerAuth.tryUnlock(_controller.text);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'PIN incorreto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('Modo Organizador', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Digite o PIN para cadastrar jogadores, torneios e resultados.',
              style: AppTextStyles.cardSubtitle,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (_) => _submit(),
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
                hintText: 'PIN',
                errorText: _error,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(label: 'Entrar', icon: Icons.check_rounded, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
