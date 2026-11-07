import 'package:flutter/material.dart';

import 'couleurs.dart';

/// Famille de couleur d'un statut métier (charte graphique, section 1).
enum Tonalite { succes, avertissement, erreur, information, neutre }

/// Couleurs des statuts métier, centralisées dans le thème (charte, section 7.5) :
/// un écran ne choisit jamais une couleur lui-même, il demande une [Tonalite].
/// La couleur accompagne toujours un libellé ou une icône, elle ne porte jamais
/// l'information seule.
@immutable
class CouleursStatut extends ThemeExtension<CouleursStatut> {
  const CouleursStatut({
    required this.succes,
    required this.avertissement,
    required this.erreur,
    required this.information,
    required this.neutre,
    required this.texteSurAvertissement,
    required this.avertissementLisibleEnTexte,
  });

  final Color succes;
  final Color avertissement;
  final Color erreur;
  final Color information;
  final Color neutre;

  /// Texte posé sur un fond avertissement (#1F1F1F, contraste 8,4:1).
  final Color texteSurAvertissement;

  /// L'ambre d'avertissement est illisible en texte sur fond clair (2,0:1),
  /// lisible sur fond sombre (8,5:1).
  final bool avertissementLisibleEnTexte;

  static const clair = CouleursStatut(
    succes: CouleursCdl.successColor,
    avertissement: CouleursCdl.warningColor,
    erreur: CouleursCdl.errorColor,
    information: CouleursCdl.infoColor,
    neutre: CouleursCdl.texteSecondaireClair,
    texteSurAvertissement: CouleursCdl.texteClair,
    avertissementLisibleEnTexte: false,
  );

  static const sombre = CouleursStatut(
    succes: CouleursCdl.successColorSombre,
    avertissement: CouleursCdl.warningColor,
    erreur: CouleursCdl.errorColorSombre,
    information: CouleursCdl.infoColorSombre,
    neutre: CouleursCdl.texteSecondaireSombre,
    texteSurAvertissement: CouleursCdl.texteClair,
    avertissementLisibleEnTexte: true,
  );

  /// Couleurs du thème courant ; à défaut d'extension, la variante claire ou sombre.
  static CouleursStatut de(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<CouleursStatut>() ?? (theme.brightness == Brightness.dark ? sombre : clair);
  }

  /// Couleur pleine d'une tonalité (icônes, bordures).
  Color couleur(Tonalite t) => switch (t) {
        Tonalite.succes => succes,
        Tonalite.avertissement => avertissement,
        Tonalite.erreur => erreur,
        Tonalite.information => information,
        Tonalite.neutre => neutre,
      };

  /// Couleur d'un texte de cette tonalité posé sur la surface.
  /// L'avertissement, illisible en texte sur fond clair, passe en texte principal.
  Color texte(Tonalite t) =>
      t == Tonalite.avertissement && !avertissementLisibleEnTexte ? texteSurAvertissement : couleur(t);

  /// Pastille : fond = couleur à 12 % d'opacité (charte, section 1).
  Color fondPastille(Tonalite t) => couleur(t).withValues(alpha: .12);

  /// Pastille : texte = couleur pleine, sauf avertissement en mode clair (#1F1F1F).
  Color textePastille(Tonalite t) => texte(t);

  /// Statut d'échéance (R-22) → tonalité.
  static Tonalite tonaliteEcheance(String statut) => switch (statut) {
        'payee' => Tonalite.succes,
        'partielle' => Tonalite.avertissement,
        'en_retard' => Tonalite.erreur,
        'annulee' => Tonalite.neutre,
        _ => Tonalite.information,
      };

  /// État d'abonnement d'une unité (R-55, R-56) → tonalité.
  static Tonalite tonaliteAbonnement(String etat) => switch (etat) {
        'actif' => Tonalite.succes,
        'grace' => Tonalite.avertissement,
        'suspendu' => Tonalite.erreur,
        _ => Tonalite.neutre,
      };

  @override
  CouleursStatut copyWith({
    Color? succes,
    Color? avertissement,
    Color? erreur,
    Color? information,
    Color? neutre,
    Color? texteSurAvertissement,
    bool? avertissementLisibleEnTexte,
  }) =>
      CouleursStatut(
        succes: succes ?? this.succes,
        avertissement: avertissement ?? this.avertissement,
        erreur: erreur ?? this.erreur,
        information: information ?? this.information,
        neutre: neutre ?? this.neutre,
        texteSurAvertissement: texteSurAvertissement ?? this.texteSurAvertissement,
        avertissementLisibleEnTexte: avertissementLisibleEnTexte ?? this.avertissementLisibleEnTexte,
      );

  @override
  CouleursStatut lerp(CouleursStatut? autre, double t) {
    if (autre == null) return this;
    return CouleursStatut(
      succes: Color.lerp(succes, autre.succes, t)!,
      avertissement: Color.lerp(avertissement, autre.avertissement, t)!,
      erreur: Color.lerp(erreur, autre.erreur, t)!,
      information: Color.lerp(information, autre.information, t)!,
      neutre: Color.lerp(neutre, autre.neutre, t)!,
      texteSurAvertissement: Color.lerp(texteSurAvertissement, autre.texteSurAvertissement, t)!,
      avertissementLisibleEnTexte: t < .5 ? avertissementLisibleEnTexte : autre.avertissementLisibleEnTexte,
    );
  }
}
