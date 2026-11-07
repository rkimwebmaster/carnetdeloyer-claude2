import 'package:flutter/material.dart';

/// Palette de la charte graphique v1.0 (docs/design/charte-graphique.md, section 1).
/// Seul endroit du code où une couleur est écrite en dur (R-130) : les écrans
/// passent toujours par le thème ou par [CouleursStatut].
class CouleursCdl {
  const CouleursCdl._();

  // Marque.
  static const primaryColor = Color(0xFF8B0000);
  static const primaryLight = Color(0xFFB71C1C);
  static const primaryDark = Color(0xFF650000);
  static const secondaryColor = Color(0xFFFFB300);
  static const secondaryDark = Color(0xFFFF8F00);

  // Sémantiques.
  static const successColor = Color(0xFF2E7D32);
  static const warningColor = Color(0xFFF9A825);
  static const errorColor = Color(0xFFC62828);
  static const errorColorSombre = Color(0xFFEF5350);
  static const infoColor = Color(0xFF1565C0);

  // Sémantiques du mode sombre que la charte ne fixe pas (section 1 : seule
  // l'erreur a une valeur sombre). Proposition à valider : même famille que
  // #EF5350 (teinte 400), car les teintes claires tombent sous 4,5:1 sur #1E1E1E.
  static const successColorSombre = Color(0xFF66BB6A);
  static const infoColorSombre = Color(0xFF42A5F5);

  // Neutres, mode clair.
  static const fondClair = Color(0xFFF8F8F8);
  static const surfaceClair = Color(0xFFFFFFFF);
  static const texteClair = Color(0xFF1F1F1F);
  static const texteSecondaireClair = Color(0xFF6B6B6B);
  static const bordureClair = Color(0xFFE5E5E5);
  static const snackbarClair = Color(0xFF252525);

  // Neutres, mode sombre.
  static const fondSombre = Color(0xFF121212);
  static const surfaceSombre = Color(0xFF1E1E1E);
  static const texteSombre = Color(0xFFFFFFFF);
  static const texteSecondaireSombre = Color(0xFFBDBDBD);
  static const bordureSombre = Color(0xFF353535);
  static const snackbarSombre = Color(0xFF303030);

  // Boutons désactivés (section 5 : gris 300 / gris 600).
  static const desactiveFond = Color(0xFFE0E0E0);
  static const desactiveTexte = Color(0xFF757575);

  // Interrupteur inactif (section 5 : gris 400).
  static const interrupteurInactif = Color(0xFFBDBDBD);

  static const blanc = Color(0xFFFFFFFF);
}
