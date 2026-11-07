import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../theme/theme.dart';

/// Affiche un AsyncValue : chargement, erreur traduite avec bouton Réessayer, données.
class VueAsync<T> extends StatelessWidget {
  const VueAsync({super.key, required this.valeur, required this.donnees, this.reessayer});

  final AsyncValue<T> valeur;
  final Widget Function(T) donnees;
  final VoidCallback? reessayer;

  @override
  Widget build(BuildContext context) {
    return switch (valeur) {
      AsyncData(:final value) => donnees(value),
      AsyncError(:final error) => EtatErreur(erreur: error, reessayer: reessayer),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class EtatErreur extends StatelessWidget {
  const EtatErreur({super.key, required this.erreur, this.reessayer});

  final Object erreur;
  final VoidCallback? reessayer;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off_outlined, size: 40),
          const SizedBox(height: 12),
          Text(messageErreur(l, erreur), textAlign: TextAlign.center),
          if (reessayer != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: reessayer, child: Text(l.actionReessayer)),
          ],
        ]),
      ),
    );
  }
}

class EtatVide extends StatelessWidget {
  const EtatVide({super.key, required this.message, this.icone = Icons.inbox_outlined, this.action});

  final String message;
  final IconData icone;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icone, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

/// Pastille de statut (charte, section 1) : fond à 12 %, texte de la tonalité,
/// toujours avec un libellé (la couleur ne porte jamais l'information seule).
class Pastille extends StatelessWidget {
  const Pastille({super.key, required this.libelle, required this.tonalite});

  final String libelle;
  final Tonalite tonalite;

  @override
  Widget build(BuildContext context) {
    final c = CouleursStatut.de(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DimensionsCdl.espaceS, vertical: 2),
      decoration: BoxDecoration(
        color: c.fondPastille(tonalite),
        borderRadius: BorderRadius.circular(DimensionsCdl.radiusMedium),
      ),
      child: Text(
        libelle,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textePastille(tonalite)),
      ),
    );
  }
}

/// Pastille de statut d'échéance (R-22).
class PastilleStatut extends StatelessWidget {
  const PastilleStatut(this.statut, {super.key});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final libelle = switch (statut) {
      'payee' => l.statutPayee,
      'partielle' => l.statutPartielle,
      'en_retard' => l.statutEn_retard,
      'annulee' => l.statutAnnulee,
      _ => l.statutA_venir,
    };
    return Pastille(libelle: libelle, tonalite: CouleursStatut.tonaliteEcheance(statut));
  }
}

/// Reçu provisoire hors ligne (R-81, R-136) : texte secondaire et bordure pointillée
/// (charte, section 1), pour ne jamais le confondre avec un reçu émis.
class CadreProvisoire extends StatelessWidget {
  const CadreProvisoire({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DimensionsCdl.margeEcran, vertical: DimensionsCdl.espaceCartes / 2),
      child: CustomPaint(
        foregroundPainter: _Pointilles(schema.onSurfaceVariant),
        child: Material(
          color: schema.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DimensionsCdl.radiusMedium))),
          clipBehavior: Clip.antiAlias,
          child: ListTileTheme.merge(
            textColor: schema.onSurfaceVariant,
            iconColor: schema.onSurfaceVariant,
            child: DefaultTextStyle.merge(style: TextStyle(color: schema.onSurfaceVariant), child: child),
          ),
        ),
      ),
    );
  }
}

class _Pointilles extends CustomPainter {
  _Pointilles(this.couleur);

  final Color couleur;

  @override
  void paint(Canvas canvas, Size taille) {
    final pinceau = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final contour = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & taille).deflate(.75),
        const Radius.circular(DimensionsCdl.radiusMedium),
      ));
    for (final m in contour.computeMetrics()) {
      for (double d = 0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), pinceau);
      }
    }
  }

  @override
  bool shouldRepaint(_Pointilles ancien) => ancien.couleur != couleur;
}

/// Icône d'une catégorie d'unité (R-83). Les noms viennent du back-office.
IconData iconeCategorie(String nom) => switch (nom) {
      'house' => Icons.house_outlined,
      'apartment' => Icons.apartment_outlined,
      'bed' => Icons.bed_outlined,
      'single_bed' => Icons.single_bed_outlined,
      'storefront' => Icons.storefront_outlined,
      'business_center' => Icons.business_center_outlined,
      'warehouse' => Icons.warehouse_outlined,
      'landscape' => Icons.landscape_outlined,
      'hotel' => Icons.hotel_outlined,
      _ => Icons.home_work_outlined,
    };

void afficherErreur(BuildContext context, Object erreur) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageErreur(context.l10n, erreur))));
}

void afficherMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// R-150 : bandeau hors ligne global.
class BandeauHorsLigne extends ConsumerWidget {
  const BandeauHorsLigne({super.key, required this.horsLigne});

  final bool horsLigne;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!horsLigne) return const SizedBox.shrink();
    // Fond avertissement, texte #1F1F1F (8,4:1) dans les deux modes.
    final c = CouleursStatut.de(context);
    return Material(
      color: c.avertissement,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DimensionsCdl.margeEcran, vertical: 6),
          child: Row(children: [
            Icon(Icons.wifi_off, size: 18, color: c.texteSurAvertissement),
            const SizedBox(width: DimensionsCdl.espaceS),
            Expanded(
              child: Text(
                context.l10n.horsLigne,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.texteSurAvertissement),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
