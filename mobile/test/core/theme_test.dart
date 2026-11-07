import 'dart:io';
import 'dart:math' as math;

import 'package:carnetdeloyer/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contraste WCAG 2.1 entre deux couleurs opaques.
double contraste(Color a, Color b) {
  double lum(Color c) {
    double canal(double v) => v <= .03928 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
    return .2126 * canal(c.r) + .7152 * canal(c.g) + .0722 * canal(c.b);
  }

  final la = lum(a), lb = lum(b);
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

Color resoudre(WidgetStateProperty<Color?>? p, [Set<WidgetState> etats = const {}]) => p!.resolve(etats)!;

void main() {
  final clair = ThemeCdl.clair();
  final sombre = ThemeCdl.sombre();

  group('charte graphique v1.0 : mode clair', () {
    test('couleurs de marque et neutres (section 1)', () {
      expect(clair.useMaterial3, isTrue);
      expect(clair.brightness, Brightness.light);
      expect(clair.colorScheme.primary, const Color(0xFF8B0000));
      expect(clair.colorScheme.secondary, const Color(0xFFFFB300));
      expect(clair.colorScheme.error, const Color(0xFFC62828));
      expect(clair.scaffoldBackgroundColor, const Color(0xFFF8F8F8));
      expect(clair.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(clair.colorScheme.onSurface, const Color(0xFF1F1F1F));
      expect(clair.colorScheme.onSurfaceVariant, const Color(0xFF6B6B6B));
      expect(clair.colorScheme.outline, const Color(0xFFE5E5E5));
      expect(clair.snackBarTheme.backgroundColor, const Color(0xFF252525));
    });

    test('plus aucune trace du vert #1F6F5C (section 7.1)', () {
      final s = clair.colorScheme;
      final couleurs = [s.primary, s.secondary, s.tertiary, s.primaryContainer, s.secondaryContainer, s.surface, s.inversePrimary];
      for (final c in [...couleurs, ...[sombre.colorScheme.primary, sombre.colorScheme.secondary]]) {
        expect(c, isNot(const Color(0xFF1F6F5C)));
        // Aucune couleur de marque à dominante verte.
        expect(c.g > c.r && c.g > c.b, isFalse, reason: 'couleur verte : $c');
      }
    });

    test('bouton principal : fond primaire, texte blanc, 50 de haut, rayon 12, sans ombre', () {
      final st = clair.filledButtonTheme.style!;
      expect(resoudre(st.backgroundColor), const Color(0xFF8B0000));
      expect(resoudre(st.foregroundColor), Colors.white);
      expect(resoudre(st.backgroundColor, {WidgetState.disabled}), const Color(0xFFE0E0E0));
      expect(resoudre(st.foregroundColor, {WidgetState.disabled}), const Color(0xFF757575));
      expect(st.minimumSize!.resolve({})!.height, 50);
      expect(st.elevation!.resolve({}), 0);
      expect((st.shape!.resolve({})! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(12));
    });

    test('bouton contour : primaire 1,5 ; bouton texte : primaire', () {
      final st = clair.outlinedButtonTheme.style!;
      expect(st.side!.resolve({})!.color, const Color(0xFF8B0000));
      expect(st.side!.resolve({})!.width, 1.5);
      expect(resoudre(clair.textButtonTheme.style!.foregroundColor), const Color(0xFF8B0000));
    });

    test('champ : bordure #E5E5E5, focus primaire 2, erreur 1 puis 2 au focus, marges 16/15', () {
      final d = clair.inputDecorationTheme;
      expect(d.enabledBorder!.borderSide.color, const Color(0xFFE5E5E5));
      expect(d.focusedBorder!.borderSide, const BorderSide(color: Color(0xFF8B0000), width: 2));
      expect(d.errorBorder!.borderSide, const BorderSide(color: Color(0xFFC62828), width: 1));
      expect(d.focusedErrorBorder!.borderSide, const BorderSide(color: Color(0xFFC62828), width: 2));
      expect(d.contentPadding, const EdgeInsets.symmetric(horizontal: 16, vertical: 15));
    });

    test('barre d\'app, carte, dialogue, feuille du bas, navigation (sections 4 et 5)', () {
      expect(clair.appBarTheme.backgroundColor, Colors.white);
      expect(clair.appBarTheme.centerTitle, isTrue);
      expect(clair.appBarTheme.elevation, 0);
      expect(clair.appBarTheme.titleTextStyle!.fontSize, 18);
      expect(clair.appBarTheme.titleTextStyle!.fontWeight, FontWeight.w700);
      expect(clair.cardTheme.elevation, 1);
      expect((clair.cardTheme.shape! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(12));
      expect((clair.dialogTheme.shape! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(16));
      expect(clair.bottomSheetTheme.showDragHandle, isTrue);
      expect(clair.bottomSheetTheme.elevation, 5);
      expect(clair.navigationBarTheme.height, 70);
      expect(clair.navigationBarTheme.elevation, 3);
      expect(clair.navigationBarTheme.iconTheme!.resolve({WidgetState.selected})!.color, const Color(0xFF8B0000));
      expect(clair.navigationBarTheme.labelTextStyle!.resolve({})!.fontSize, 11);
      expect(clair.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(clair.progressIndicatorTheme.color, const Color(0xFF8B0000));
    });

    test('échelle de texte (section 3)', () {
      final t = clair.textTheme;
      final attendu = {
        t.displayLarge: (32.0, FontWeight.w700),
        t.displayMedium: (28.0, FontWeight.w700),
        t.displaySmall: (24.0, FontWeight.w700),
        t.headlineLarge: (22.0, FontWeight.w700),
        t.headlineMedium: (20.0, FontWeight.w700),
        t.headlineSmall: (18.0, FontWeight.w600),
        t.titleLarge: (18.0, FontWeight.w600),
        t.titleMedium: (16.0, FontWeight.w600),
        t.titleSmall: (14.0, FontWeight.w600),
        t.bodyLarge: (16.0, FontWeight.w400),
        t.bodyMedium: (14.0, FontWeight.w400),
        t.bodySmall: (12.0, FontWeight.w400),
        t.labelLarge: (14.0, FontWeight.w600),
      };
      attendu.forEach((style, v) {
        expect(style!.fontSize, v.$1);
        expect(style.fontWeight, v.$2);
      });
      expect(t.bodySmall!.color, const Color(0xFF6B6B6B));
    });
  });

  group('charte graphique v1.0 : mode sombre (sections 5 et 7.3)', () {
    test('neutres sombres', () {
      expect(sombre.brightness, Brightness.dark);
      expect(sombre.scaffoldBackgroundColor, const Color(0xFF121212));
      expect(sombre.colorScheme.surface, const Color(0xFF1E1E1E));
      expect(sombre.colorScheme.onSurface, Colors.white);
      expect(sombre.colorScheme.onSurfaceVariant, const Color(0xFFBDBDBD));
      expect(sombre.colorScheme.outline, const Color(0xFF353535));
      expect(sombre.colorScheme.error, const Color(0xFFEF5350));
      expect(sombre.snackBarTheme.backgroundColor, const Color(0xFF303030));
    });

    test('fonds pleins en primaire claire, accent ambre', () {
      expect(resoudre(sombre.filledButtonTheme.style!.backgroundColor), const Color(0xFFB71C1C));
      expect(resoudre(sombre.filledButtonTheme.style!.foregroundColor), Colors.white);
      expect(sombre.floatingActionButtonTheme.backgroundColor, const Color(0xFFB71C1C));
      const ambre = Color(0xFFFFB300);
      expect(sombre.outlinedButtonTheme.style!.side!.resolve({})!.color, ambre);
      expect(resoudre(sombre.outlinedButtonTheme.style!.foregroundColor), ambre);
      expect(resoudre(sombre.textButtonTheme.style!.foregroundColor), ambre);
      expect(sombre.navigationBarTheme.iconTheme!.resolve({WidgetState.selected})!.color, ambre);
      expect(sombre.navigationBarTheme.indicatorColor, const Color(0xFFB71C1C).withValues(alpha: .20));
      expect(sombre.progressIndicatorTheme.color, ambre);
      // Section 7.4 : focus en ambre, la primaire claire étant sous 3:1.
      expect(sombre.inputDecorationTheme.focusedBorder!.borderSide, const BorderSide(color: ambre, width: 2));
    });

    test('éléments qui manquaient (section 7.3) : tous définis', () {
      expect(sombre.textTheme.labelLarge, isNotNull);
      expect(sombre.textTheme.labelLarge!.fontWeight, FontWeight.w600);
      expect(sombre.appBarTheme.iconTheme, isNotNull);
      expect(sombre.inputDecorationTheme.focusedErrorBorder, isNotNull);
      expect(sombre.switchTheme.thumbColor, isNotNull);
      expect(sombre.checkboxTheme.fillColor, isNotNull);
      expect((sombre.checkboxTheme.shape! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(5));
      expect(sombre.tooltipTheme.decoration, isNotNull);
    });

    test('le bordeaux n\'est jamais utilisé en texte ou en contour sur fond sombre (section 2)', () {
      const interdits = [Color(0xFF8B0000), Color(0xFFB71C1C)];
      expect(interdits, isNot(contains(sombre.colorScheme.primary)));
      expect(interdits, isNot(contains(resoudre(sombre.textButtonTheme.style!.foregroundColor))));
      expect(interdits, isNot(contains(sombre.outlinedButtonTheme.style!.side!.resolve({})!.color)));
      expect(interdits, isNot(contains(sombre.inputDecorationTheme.focusedBorder!.borderSide.color)));
    });
  });

  group('contrastes WCAG (section 2)', () {
    for (final (nom, t) in [('clair', clair), ('sombre', sombre)]) {
      final s = t.colorScheme;
      test('$nom : textes ≥ 4,5:1', () {
        expect(contraste(s.onSurface, s.surface), greaterThanOrEqualTo(4.5));
        expect(contraste(s.onSurfaceVariant, s.surface), greaterThanOrEqualTo(4.5));
        expect(contraste(s.onSurfaceVariant, t.scaffoldBackgroundColor), greaterThanOrEqualTo(4.5));
        // Texte des boutons texte et contour (accent) sur la surface.
        expect(contraste(resoudre(t.textButtonTheme.style!.foregroundColor), s.surface), greaterThanOrEqualTo(4.5));
        expect(
          contraste(resoudre(t.filledButtonTheme.style!.foregroundColor), resoudre(t.filledButtonTheme.style!.backgroundColor)),
          greaterThanOrEqualTo(4.5),
        );
        expect(contraste(s.onSecondaryContainer, s.secondaryContainer), greaterThanOrEqualTo(4.5));
        expect(contraste(s.onError, s.error), greaterThanOrEqualTo(4.5));
        expect(contraste(Colors.white, t.snackBarTheme.backgroundColor!), greaterThanOrEqualTo(4.5));
      });

      test('$nom : focus et icône active ≥ 3:1', () {
        expect(contraste(t.inputDecorationTheme.focusedBorder!.borderSide.color, s.surface), greaterThanOrEqualTo(3));
        expect(contraste(t.navigationBarTheme.iconTheme!.resolve({WidgetState.selected})!.color!, s.surface), greaterThanOrEqualTo(3));
      });

      test('$nom : textes de statut sur la surface ≥ 4,5:1', () {
        final c = t.extension<CouleursStatut>()!;
        for (final tonalite in Tonalite.values) {
          expect(contraste(c.texte(tonalite), s.surface), greaterThanOrEqualTo(4.5), reason: '$tonalite');
        }
      });
    }

    // Écarts signalés dans la note de livraison : avec les couleurs fixées par la charte,
    // deux pastilles restent sous 4,5:1. Couleurs gardées telles quelles, à trancher.
    const ecartsConnus = {('clair', Tonalite.succes): 4.37, ('sombre', Tonalite.erreur): 4.17};

    test('pastilles : texte sur fond à 12 % ≥ 4,5:1 (hors écarts connus)', () {
      for (final (nom, t) in [('clair', clair), ('sombre', sombre)]) {
        final c = t.extension<CouleursStatut>()!;
        for (final tonalite in Tonalite.values) {
          if (ecartsConnus.containsKey((nom, tonalite))) continue;
          final fond = Color.alphaBlend(c.fondPastille(tonalite), t.colorScheme.surface);
          expect(contraste(c.textePastille(tonalite), fond), greaterThanOrEqualTo(4.5), reason: '$nom $tonalite');
        }
      }
    });

    test('pastilles sous le seuil : écarts connus de la charte, mesurés', () {
      final themes = {'clair': clair, 'sombre': sombre};
      ecartsConnus.forEach((cle, attendu) {
        final t = themes[cle.$1]!;
        final c = t.extension<CouleursStatut>()!;
        final fond = Color.alphaBlend(c.fondPastille(cle.$2), t.colorScheme.surface);
        // Si la charte change ces couleurs, ce test échoue : retirer alors l'écart de la liste.
        expect(contraste(c.textePastille(cle.$2), fond), closeTo(attendu, .01), reason: '$cle');
      });
    });
  });

  group('couleurs des statuts (section 1, section 7.5)', () {
    test('correspondances échéances et abonnements', () {
      expect(CouleursStatut.tonaliteEcheance('payee'), Tonalite.succes);
      expect(CouleursStatut.tonaliteEcheance('partielle'), Tonalite.avertissement);
      expect(CouleursStatut.tonaliteEcheance('en_retard'), Tonalite.erreur);
      expect(CouleursStatut.tonaliteEcheance('a_venir'), Tonalite.information);
      expect(CouleursStatut.tonaliteEcheance('annulee'), Tonalite.neutre);
      expect(CouleursStatut.tonaliteAbonnement('grace'), Tonalite.avertissement);
      expect(CouleursStatut.tonaliteAbonnement('suspendu'), Tonalite.erreur);
    });

    test('avertissement : texte #1F1F1F en clair, ambre lisible en sombre', () {
      expect(CouleursStatut.clair.textePastille(Tonalite.avertissement), const Color(0xFF1F1F1F));
      expect(CouleursStatut.sombre.textePastille(Tonalite.avertissement), const Color(0xFFF9A825));
      expect(CouleursStatut.clair.textePastille(Tonalite.erreur), const Color(0xFFC62828));
      expect(CouleursStatut.clair.fondPastille(Tonalite.erreur), const Color(0xFFC62828).withValues(alpha: .12));
    });

    test('l\'extension est installée dans les deux thèmes', () {
      expect(clair.extension<CouleursStatut>(), CouleursStatut.clair);
      expect(sombre.extension<CouleursStatut>(), CouleursStatut.sombre);
    });
  });

  test('R-130 : aucune couleur écrite en dur hors de lib/core/theme', () {
    final enDur = RegExp(r'Color\(0x|Colors\.(?!transparent\b)');
    final fautifs = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final chemin = f.path.replaceAll('\\', '/');
      if (!chemin.endsWith('.dart') || chemin.contains('/core/theme/') || chemin.contains('/generated/')) continue;
      if (chemin.endsWith('.g.dart') || chemin.endsWith('.freezed.dart')) continue;
      final lignes = f.readAsLinesSync();
      for (var i = 0; i < lignes.length; i++) {
        if (enDur.hasMatch(lignes[i])) fautifs.add('$chemin:${i + 1}');
      }
    }
    expect(fautifs, isEmpty);
  });
}
