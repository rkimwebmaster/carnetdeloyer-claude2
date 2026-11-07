import 'package:flutter/material.dart';

import 'couleurs.dart';
import 'couleurs_statut.dart';
import 'dimensions.dart';

export 'couleurs.dart';
export 'couleurs_statut.dart';
export 'dimensions.dart';

/// Thème de l'app, conforme à la charte graphique v1.0 (docs/design/charte-graphique.md).
/// Material 3, mode clair et mode sombre.
///
/// Règle du mode sombre (charte, section 5) : le bordeaux n'est pas lisible sur fond
/// sombre (2,5:1). La primaire claire ne sert qu'en fond plein (boutons, bouton flottant) ;
/// l'ambre devient la couleur d'accent (contours, liens, onglet actif, focus, chargement).
/// Pour que les composants Material qui écrivent en « primary » restent lisibles,
/// le `primary` du schéma sombre est donc l'ambre, et les fonds pleins sont posés
/// explicitement en primaire claire.
class ThemeCdl {
  const ThemeCdl._();

  static ThemeData clair() => _construire(_Palette.clair);

  static ThemeData sombre() => _construire(_Palette.sombre);

  static ThemeData _construire(_Palette p) {
    final schema = ColorScheme(
      brightness: p.luminosite,
      primary: p.accent,
      onPrimary: p.surAccent,
      primaryContainer: p.fondPlein,
      onPrimaryContainer: CouleursCdl.blanc,
      secondary: CouleursCdl.secondaryColor,
      onSecondary: CouleursCdl.texteClair,
      // Bouton tonal et indicateurs : l'ambre sert de fond, texte noir (11,7:1).
      secondaryContainer: CouleursCdl.secondaryColor,
      onSecondaryContainer: CouleursCdl.texteClair,
      tertiary: CouleursCdl.secondaryColor,
      onTertiary: CouleursCdl.texteClair,
      tertiaryContainer: CouleursCdl.warningColor,
      onTertiaryContainer: CouleursCdl.texteClair,
      error: p.erreur,
      onError: p.surErreur,
      errorContainer: Color.alphaBlend(p.erreur.withValues(alpha: .12), p.surface),
      onErrorContainer: p.texte,
      surface: p.surface,
      onSurface: p.texte,
      onSurfaceVariant: p.texteSecondaire,
      surfaceDim: p.fond,
      surfaceBright: p.surface,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface,
      surfaceContainerHighest: p.fond,
      outline: p.bordure,
      outlineVariant: p.bordure,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: p.snackbar,
      onInverseSurface: CouleursCdl.blanc,
      inversePrimary: p.luminosite == Brightness.light ? CouleursCdl.secondaryColor : CouleursCdl.primaryColor,
      // Pas de teinte rosée sur les surfaces élevées : les surfaces restent neutres.
      surfaceTint: Colors.transparent,
    );

    final texte = _texte(p);
    const rayonMoyen = BorderRadius.all(Radius.circular(DimensionsCdl.radiusMedium));
    const formeMoyenne = RoundedRectangleBorder(borderRadius: rayonMoyen);
    const tailleBouton = Size.fromHeight(DimensionsCdl.buttonHeight);
    const margesBouton = EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    OutlineInputBorder bordure(Color couleur, double largeur) =>
        OutlineInputBorder(borderRadius: rayonMoyen, borderSide: BorderSide(color: couleur, width: largeur));

    return ThemeData(
      useMaterial3: true,
      brightness: p.luminosite,
      colorScheme: schema,
      scaffoldBackgroundColor: p.fond,
      canvasColor: p.surface,
      dividerColor: p.bordure,
      textTheme: texte,
      extensions: [p.statuts],
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.texte,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: texte.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: p.texte, size: DimensionsCdl.iconeActive),
        actionsIconTheme: IconThemeData(color: p.texte, size: DimensionsCdl.iconeActive),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.fondPlein,
          foregroundColor: CouleursCdl.blanc,
          disabledBackgroundColor: p.desactiveFond,
          disabledForegroundColor: p.desactiveTexte,
          minimumSize: tailleBouton,
          padding: margesBouton,
          elevation: 0,
          shape: formeMoyenne,
          textStyle: texte.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.fondPlein,
          foregroundColor: CouleursCdl.blanc,
          disabledBackgroundColor: p.desactiveFond,
          disabledForegroundColor: p.desactiveTexte,
          minimumSize: tailleBouton,
          padding: margesBouton,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: formeMoyenne,
          textStyle: texte.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.accent,
          side: BorderSide(color: p.accent, width: 1.5),
          minimumSize: tailleBouton,
          padding: margesBouton,
          shape: formeMoyenne,
          textStyle: texte.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DimensionsCdl.radiusSmall))),
          textStyle: texte.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.fondPlein,
        foregroundColor: CouleursCdl.blanc,
        elevation: 1,
        shape: formeMoyenne,
        extendedTextStyle: texte.labelLarge,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: p.bordureControle)),
          shape: const WidgetStatePropertyAll(formeMoyenne),
          backgroundColor: WidgetStateProperty.resolveWith(
            (e) => e.contains(WidgetState.selected) ? p.fondPlein : p.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (e) => e.contains(WidgetState.selected) ? CouleursCdl.blanc : p.texte,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (e) => e.contains(WidgetState.selected) ? CouleursCdl.blanc : p.texte,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: bordure(p.bordure, 1),
        enabledBorder: bordure(p.bordure, 1),
        disabledBorder: bordure(p.bordure, 1),
        focusedBorder: bordure(p.focus, 2),
        errorBorder: bordure(p.erreur, 1),
        focusedErrorBorder: bordure(p.erreur, 2),
        labelStyle: texte.bodyMedium?.copyWith(color: p.texteSecondaire),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((e) {
          if (e.contains(WidgetState.error)) return TextStyle(color: p.erreur);
          if (e.contains(WidgetState.focused)) return TextStyle(color: p.focus);
          return TextStyle(color: p.texteSecondaire);
        }),
        hintStyle: texte.bodyMedium?.copyWith(color: p.texteSecondaire),
        helperStyle: texte.bodySmall,
        errorStyle: texte.bodySmall?.copyWith(color: p.erreur),
        prefixIconColor: p.texteSecondaire,
        suffixIconColor: p.texteSecondaire,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: formeMoyenne,
        // Écart signalé : la charte dit « sans marge », mais toutes les listes actuelles
        // comptent sur cette marge. Gardée ici (marge d'écran 16, espace entre cartes 12)
        // en attendant de la reporter écran par écran.
        margin: const EdgeInsets.symmetric(horizontal: DimensionsCdl.margeEcran, vertical: DimensionsCdl.espaceCartes / 2),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.texteSecondaire,
        textColor: p.texte,
        titleTextStyle: texte.titleSmall,
        subtitleTextStyle: texte.bodySmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: DimensionsCdl.hauteurNavigation,
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        indicatorColor: p.indicateurNavigation,
        iconTheme: WidgetStateProperty.resolveWith((e) => e.contains(WidgetState.selected)
            ? IconThemeData(color: p.accent, size: DimensionsCdl.iconeActive)
            : IconThemeData(color: p.texteSecondaire, size: DimensionsCdl.iconeInactive)),
        labelTextStyle: WidgetStateProperty.resolveWith((e) => TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: e.contains(WidgetState.selected) ? p.accent : p.texteSecondaire,
            )),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: p.surface, surfaceTintColor: Colors.transparent, elevation: 2),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        indicatorColor: p.indicateurNavigation,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.snackbar,
        contentTextStyle: const TextStyle(color: CouleursCdl.blanc, fontSize: 14),
        actionTextColor: CouleursCdl.secondaryColor,
        shape: formeMoyenne,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DimensionsCdl.radiusLarge))),
        titleTextStyle: texte.headlineMedium,
        contentTextStyle: texte.bodyMedium?.copyWith(color: p.texteSecondaire),
        iconColor: p.accent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 5,
        showDragHandle: true,
        dragHandleColor: p.texteSecondaire,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(DimensionsCdl.radiusXLarge)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(color: p.surface, surfaceTintColor: Colors.transparent, textStyle: texte.bodyMedium),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (e) => e.contains(WidgetState.selected) ? p.accent : CouleursCdl.interrupteurInactif,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (e) => e.contains(WidgetState.selected) ? p.accent.withValues(alpha: .35) : p.bordure,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (e) => e.contains(WidgetState.selected) ? Colors.transparent : CouleursCdl.interrupteurInactif,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DimensionsCdl.radiusCaseACocher))),
        fillColor: WidgetStateProperty.resolveWith((e) => e.contains(WidgetState.selected) ? p.accent : Colors.transparent),
        checkColor: WidgetStatePropertyAll(p.surAccent),
        side: BorderSide(color: p.texteSecondaire, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((e) => e.contains(WidgetState.selected) ? p.accent : p.texteSecondaire),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.snackbar,
          borderRadius: const BorderRadius.all(Radius.circular(DimensionsCdl.radiusSmall)),
        ),
        textStyle: const TextStyle(color: CouleursCdl.blanc, fontSize: 12),
      ),
      dividerTheme: DividerThemeData(color: p.bordure, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: p.texte, size: DimensionsCdl.iconeActive),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        side: BorderSide(color: p.bordure),
        labelStyle: texte.bodyMedium,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DimensionsCdl.radiusSmall))),
      ),
    );
  }

  /// Échelle de texte (charte, section 3). Police système, graisses 400, 600, 700.
  /// Fusionnée avec la typographie Material de la plateforme (police, interlignage).
  static TextTheme _texte(_Palette p) {
    final base = p.luminosite == Brightness.light ? Typography.material2021().black : Typography.material2021().white;
    TextStyle s(double taille, FontWeight graisse, [Color? couleur]) =>
        TextStyle(fontSize: taille, fontWeight: graisse, color: couleur ?? p.texte);
    return base.merge(TextTheme(
      displayLarge: s(32, FontWeight.w700),
      displayMedium: s(28, FontWeight.w700),
      displaySmall: s(24, FontWeight.w700),
      headlineLarge: s(22, FontWeight.w700),
      headlineMedium: s(20, FontWeight.w700),
      headlineSmall: s(18, FontWeight.w600),
      titleLarge: s(18, FontWeight.w600),
      titleMedium: s(16, FontWeight.w600),
      titleSmall: s(14, FontWeight.w600),
      bodyLarge: s(16, FontWeight.w400),
      bodyMedium: s(14, FontWeight.w400),
      bodySmall: s(12, FontWeight.w400, p.texteSecondaire),
      labelLarge: s(14, FontWeight.w600),
      labelMedium: s(12, FontWeight.w600),
      labelSmall: s(11, FontWeight.w600),
    ));
  }
}

/// Valeurs qui changent entre le mode clair et le mode sombre.
class _Palette {
  const _Palette({
    required this.luminosite,
    required this.accent,
    required this.surAccent,
    required this.fondPlein,
    required this.focus,
    required this.erreur,
    required this.surErreur,
    required this.fond,
    required this.surface,
    required this.texte,
    required this.texteSecondaire,
    required this.bordure,
    required this.bordureControle,
    required this.snackbar,
    required this.indicateurNavigation,
    required this.desactiveFond,
    required this.desactiveTexte,
    required this.statuts,
  });

  final Brightness luminosite;

  /// Couleur d'accent : texte des liens, contours, onglet actif, chargement.
  final Color accent;
  final Color surAccent;

  /// Fond des boutons pleins.
  final Color fondPlein;

  /// Bordure de focus des champs.
  final Color focus;
  final Color erreur;
  final Color surErreur;
  final Color fond;
  final Color surface;
  final Color texte;
  final Color texteSecondaire;
  final Color bordure;
  final Color bordureControle;
  final Color snackbar;
  final Color indicateurNavigation;
  final Color desactiveFond;
  final Color desactiveTexte;
  final CouleursStatut statuts;

  static final clair = _Palette(
    luminosite: Brightness.light,
    accent: CouleursCdl.primaryColor,
    surAccent: CouleursCdl.blanc,
    fondPlein: CouleursCdl.primaryColor,
    focus: CouleursCdl.primaryColor,
    erreur: CouleursCdl.errorColor,
    surErreur: CouleursCdl.blanc,
    fond: CouleursCdl.fondClair,
    surface: CouleursCdl.surfaceClair,
    texte: CouleursCdl.texteClair,
    texteSecondaire: CouleursCdl.texteSecondaireClair,
    bordure: CouleursCdl.bordureClair,
    bordureControle: CouleursCdl.texteSecondaireClair,
    snackbar: CouleursCdl.snackbarClair,
    indicateurNavigation: CouleursCdl.primaryColor.withValues(alpha: .12),
    desactiveFond: CouleursCdl.desactiveFond,
    desactiveTexte: CouleursCdl.desactiveTexte,
    statuts: CouleursStatut.clair,
  );

  static final sombre = _Palette(
    luminosite: Brightness.dark,
    accent: CouleursCdl.secondaryColor,
    surAccent: CouleursCdl.texteClair,
    fondPlein: CouleursCdl.primaryLight,
    // Charte 7.4 : la primaire claire (2,5:1) est sous le seuil de 3:1 ; focus en ambre.
    focus: CouleursCdl.secondaryColor,
    erreur: CouleursCdl.errorColorSombre,
    // Blanc sur #EF5350 : 3,5:1 ; texte foncé : 4,7:1.
    surErreur: CouleursCdl.texteClair,
    fond: CouleursCdl.fondSombre,
    surface: CouleursCdl.surfaceSombre,
    texte: CouleursCdl.texteSombre,
    texteSecondaire: CouleursCdl.texteSecondaireSombre,
    bordure: CouleursCdl.bordureSombre,
    bordureControle: CouleursCdl.texteSecondaireSombre,
    snackbar: CouleursCdl.snackbarSombre,
    indicateurNavigation: CouleursCdl.primaryLight.withValues(alpha: .20),
    // Non fixé par la charte (proposition) : gris 300 éblouit sur fond sombre ;
    // bouton désactivé en bordure sombre et texte secondaire.
    desactiveFond: CouleursCdl.bordureSombre,
    desactiveTexte: CouleursCdl.texteSecondaireSombre,
    statuts: CouleursStatut.sombre,
  );
}
