# 2026-11-04 : étape 0, CI verte (test de concurrence)

Règles concernées : R-33 (reçus numérotés sans trou), R-137 (paiements idempotents), R-154 (CI bloquante).

## Constat
- Le test `api/tests/Concurrence/encaissements-paralleles.sh` échouait par intermittence.
- Ce n'est **pas** propre à PHP 8.2 : le même échec existait déjà en PHP 8.3 (runs du 27/10 sur `09e1f6a` et `b80764d`).
- Les requêtes en échec étaient coupées au niveau réseau (codes curl 52 et 56, sans réponse HTTP).
  Le serveur utilisé est le serveur PHP intégré (`php -S`, 8 workers), réservé aux tests.
- Dans tous les échecs, l'intégrité était respectée : aucun doublon, reçus numérotés sans trou.

## Correction
- Le script renvoie la même requête, **avec la même clé d'idempotence**, si la connexion est coupée
  (`curl --retry 5 --retry-all-errors`, sans `--fail` : une réponse HTTP d'erreur n'est jamais renvoyée).
  C'est le comportement attendu du téléphone (R-137), et le test le vérifie désormais aussi.
- Le contrôle final est inchangé : exactement 21 paiements, 21 000 imputés, reçus 1..21 distincts.
- Diagnostic ajouté et conservé : codes de sortie curl, fin du journal du serveur, processus PHP,
  erreurs PHP, requête de contrôle après la rafale.

## Tests réellement exécutés (CI GitHub, PHP 8.2.35, MariaDB 10.11)
- PHPUnit : 115 tests verts.
- Concurrence : voir le run CI de ce commit (résultat noté dans AVANCEMENT.md).
- Flutter (analyse, tests, APK) et test de bout en bout : verts sur `e6a20c5`.

## Point ouvert
- La cause exacte des coupures n'est pas identifiée (serveur intégré sous rafale). La production
  (Apache/PHP-FPM) n'est pas concernée par ce serveur, mais un test de charge sur un serveur
  proche de la production est recommandé avant le lancement (non exécuté).
