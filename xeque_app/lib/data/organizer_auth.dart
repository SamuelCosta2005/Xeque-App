import 'package:flutter/material.dart';

/// Controle de "modo organizador" via PIN simples.
///
/// IMPORTANTE (ver README): isso é só uma trava de interface. A regra do
/// Firestore libera escrita pra qualquer um — quem garante que só o
/// organizador edita é o app escondendo os botões até o PIN certo ser
/// digitado. Para segurança de verdade, evoluir para Firebase Auth depois.
class OrganizerAuth {
  OrganizerAuth._();

  /// Troque aqui o PIN do organizador (ou carregue de um doc do Firestore
  /// se quiser poder mudar sem recompilar o app).
  static const String _pin = '1234';

  static final ValueNotifier<bool> isOrganizer = ValueNotifier<bool>(false);

  static bool tryUnlock(String input) {
    final ok = input.trim() == _pin;
    if (ok) isOrganizer.value = true;
    return ok;
  }

  static void lock() => isOrganizer.value = false;
}
