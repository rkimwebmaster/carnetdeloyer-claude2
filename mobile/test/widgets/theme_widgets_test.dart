import 'package:carnetdeloyer/core/l10n/l10n.dart';
import 'package:carnetdeloyer/core/theme/theme.dart';
import 'package:carnetdeloyer/core/widgets/communs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> monter(WidgetTester tester, Widget enfant, {ThemeData? theme}) => tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: theme,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
        home: Scaffold(body: enfant),
      ),
    ));

Color couleurTexte(WidgetTester tester, String texte) => tester.widget<Text>(find.text(texte)).style!.color!;

Color fondPastille(WidgetTester tester, String texte) {
  final boite = tester.widget<Container>(find.ancestor(of: find.text(texte), matching: find.byType(Container)).first);
  return (boite.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('pastilles d\'échéance, mode clair (charte, section 1)', (tester) async {
    await monter(
      tester,
      const Column(children: [
        PastilleStatut('payee'),
        PastilleStatut('partielle'),
        PastilleStatut('en_retard'),
        PastilleStatut('a_venir'),
      ]),
      theme: ThemeCdl.clair(),
    );
    expect(couleurTexte(tester, 'Payée'), const Color(0xFF2E7D32));
    expect(fondPastille(tester, 'Payée'), const Color(0xFF2E7D32).withValues(alpha: .12));
    // Avertissement : texte #1F1F1F sur fond ambre à 12 %.
    expect(couleurTexte(tester, 'Partielle'), const Color(0xFF1F1F1F));
    expect(fondPastille(tester, 'Partielle'), const Color(0xFFF9A825).withValues(alpha: .12));
    expect(couleurTexte(tester, 'En retard'), const Color(0xFFC62828));
    expect(couleurTexte(tester, 'À venir'), const Color(0xFF1565C0));
    expect(tester.widget<Text>(find.text('Payée')).style!.fontWeight, FontWeight.w600);
    expect(tester.widget<Text>(find.text('Payée')).style!.fontSize, 12);
  });

  testWidgets('pastilles d\'échéance, mode sombre', (tester) async {
    await monter(
      tester,
      const Column(children: [PastilleStatut('partielle'), PastilleStatut('en_retard')]),
      theme: ThemeCdl.sombre(),
    );
    expect(couleurTexte(tester, 'Partielle'), const Color(0xFFF9A825));
    expect(couleurTexte(tester, 'En retard'), const Color(0xFFEF5350));
  });

  testWidgets('sans extension de thème, les couleurs de statut claires s\'appliquent', (tester) async {
    await monter(tester, const PastilleStatut('en_retard'));
    expect(couleurTexte(tester, 'En retard'), const Color(0xFFC62828));
  });

  testWidgets('reçu provisoire : texte secondaire et bordure pointillée (R-81, R-136)', (tester) async {
    await monter(
      tester,
      const CadreProvisoire(child: ListTile(title: Text('10 USD'), subtitle: Text('REÇU PROVISOIRE'))),
      theme: ThemeCdl.clair(),
    );
    final peinture = tester.widgetList<CustomPaint>(
      find.descendant(of: find.byType(CadreProvisoire), matching: find.byType(CustomPaint)),
    ).where((p) => p.foregroundPainter != null);
    expect(peinture, isNotEmpty);
    final titre = tester.renderObject<RenderParagraph>(find.text('10 USD'));
    expect(titre.text.style!.color, const Color(0xFF6B6B6B));
  });

  testWidgets('bandeau hors ligne : fond avertissement, texte #1F1F1F (R-150)', (tester) async {
    await monter(tester, const BandeauHorsLigne(horsLigne: true), theme: ThemeCdl.sombre());
    final fond = tester.widget<Material>(find.descendant(of: find.byType(BandeauHorsLigne), matching: find.byType(Material)).first);
    expect(fond.color, const Color(0xFFF9A825));
    final texte = tester.widget<Text>(find.descendant(of: find.byType(BandeauHorsLigne), matching: find.byType(Text)));
    expect(texte.style!.color, const Color(0xFF1F1F1F));
  });

  testWidgets('l\'app complète démarre avec le thème bordeaux, clair et sombre', (tester) async {
    for (final theme in [ThemeCdl.clair(), ThemeCdl.sombre()]) {
      await monter(
        tester,
        Column(children: [
          FilledButton(onPressed: () {}, child: const Text('Valider')),
          OutlinedButton(onPressed: () {}, child: const Text('Annuler')),
          const TextField(decoration: InputDecoration(labelText: 'Montant')),
          Switch(value: true, onChanged: (_) {}),
          Checkbox(value: true, onChanged: (_) {}),
          const CircularProgressIndicator(),
        ]),
        theme: theme,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(FilledButton)).height, 50);
    }
  });
}
