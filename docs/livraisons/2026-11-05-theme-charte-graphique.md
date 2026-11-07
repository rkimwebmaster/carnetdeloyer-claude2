# 2026-11-05 — Thème conforme à la charte graphique v1.0

Le thème vert (`#1F6F5C`) est remplacé par le thème bordeaux et ambre de `docs/design/charte-graphique.md`.
Règles concernées : R-130 (thème dans `core/`), R-22 (statuts d'échéance), R-55 et R-56 (grâce, suspension),
R-81 et R-136 (reçu provisoire), R-150 (bandeau hors ligne).

## Contenu

Écarts de la section 7 de la charte :

| Écart | Traitement |
|---|---|
| 7.1 Thème vert | `mobile/lib/core/theme/` : `couleurs.dart` (palette), `dimensions.dart` (rayons, hauteurs, espacements), `theme.dart` (clair et sombre, Material 3). |
| 7.2 `withOpacity` | Aucun appel restant ; tout passe par `withValues(alpha:)`. |
| 7.3 Mode sombre incomplet | `labelLarge`, icône de barre d'app, `focusedErrorBorder`, interrupteur, case à cocher et info-bulle définis dans les deux modes. |
| 7.4 Focus sombre | Bordure de focus en ambre (9,3:1) au lieu de la primaire claire (2,5:1). |
| 7.5 Statuts | Extension de thème `CouleursStatut` et `Tonalite` ; plus aucune couleur choisie dans un écran. |

Autres changements :

- **Mode sombre** : le `primary` du schéma est l'ambre, pour que tous les composants Material qui écrivent en « primary » (liens, onglet actif, chargement) restent lisibles. Les fonds pleins (bouton principal, bouton flottant) sont posés explicitement en primaire claire `#B71C1C`.
- **Pastilles** : nouveau widget `Pastille(libelle, tonalite)`. `PastilleStatut` s'appuie dessus. Le texte d'avertissement est `#1F1F1F` en mode clair.
- **Abonnements** : la période de grâce et la suspension s'affichent en pastille (avertissement, erreur) au lieu d'un texte rouge.
- **Reçu provisoire** (`CadreProvisoire`) : texte secondaire et bordure pointillée, comme le prévoit la charte.
- **Bandeau hors ligne** : fond avertissement, texte `#1F1F1F` (8,4:1).
- **Pages web de l'API** (reçu public `/r/{jeton}`, confidentialité) : couleurs de la charte via des variables CSS ; le vert est supprimé.

## Écarts à trancher (charte)

Les couleurs de la charte ont été gardées telles quelles. Points à valider :

1. **Pastille « succès » en mode clair** : `#2E7D32` sur son fond à 12 % donne 4,37:1, sous le seuil de 4,5:1.
2. **Pastille « erreur » en mode sombre** : `#EF5350` sur son fond à 12 % donne 4,17:1, sous le seuil.
3. **Statuts en mode sombre** : la charte ne fixe que l'erreur (`#EF5350`). Proposition appliquée, de la même famille (teinte 400) : succès `#66BB6A` (7,1:1), information `#42A5F5` (6,3:1). Les teintes claires tombent sous 3,3:1 sur `#1E1E1E`.
4. **Erreur pleine en mode sombre** : blanc sur `#EF5350` donne 3,5:1. Texte `#1F1F1F` retenu (4,7:1).
5. **Bouton désactivé en mode sombre** (non fixé) : fond `#353535`, texte `#BDBDBD`. Le gris 300 éblouit sur fond sombre.
6. **Interrupteur sombre** (« à définir ») : pouce ambre.
7. **Marge des cartes** : la charte dit « sans marge », mais toutes les listes actuelles comptent sur une marge de thème. Gardée à 16 horizontal et 6 vertical (12 entre cartes) ; à reporter écran par écran si la règle est confirmée.
8. **Bouton tonal** : la charte ne le prévoit pas. Il prend le style du bouton principal.

## Tests exécutés

| Commande | Résultat |
|---|---|
| `cd mobile && flutter analyze` | aucun problème |
| `cd mobile && flutter test` | 63 réussis, 1 ignoré (déjà ignoré avant ; 34 existants et 29 nouveaux) |
| `cd api && php vendor/bin/phpunit` | 115 tests, 893 assertions, OK |
| `cd api && php bin/console lint:twig templates` | 3 fichiers valides |
| `./scripts/test-integration.sh` | parcours bailleur complet sur la vraie API, OK |

Nouveaux tests :

- `test/core/theme_test.dart` : valeurs de la charte (couleurs, typographie, formes, composants), mode sombre complet, contrastes WCAG calculés, correspondance des statuts, plus aucune trace de vert.
- `test/core/theme_test.dart` contient aussi une garde R-130 : aucune couleur écrite en dur hors de `lib/core/theme/`.
- `test/widgets/theme_widgets_test.dart` : pastilles en clair et en sombre, reçu provisoire, bandeau hors ligne, rendu des composants dans les deux modes.

Les captures ont été vérifiées visuellement en clair et en sombre, avec la police Roboto. Les tests PHP ont tourné en PHP 8.3 en local ; aucun code PHP n'a été modifié, et l'intégration continue reste en 8.2.
