# 2026-11-04 : étape 0, CI verte (test de concurrence)

Règles concernées : R-33 (reçus numérotés sans trou), R-137 (paiements idempotents), R-154 (CI bloquante).

## Constat
- Le test `api/tests/Concurrence/encaissements-paralleles.sh` échouait par intermittence.
- Ce n'est **pas** propre à PHP 8.2 : le même échec existait déjà en PHP 8.3 (runs du 27/10 sur `09e1f6a` et `b80764d`).
- Les requêtes en échec étaient coupées au niveau réseau (codes curl 52 et 56, sans réponse HTTP).
  Le serveur utilisé est le serveur PHP intégré (`php -S`, 8 workers), réservé aux tests.
- Dans tous les échecs, l'intégrité était respectée : aucun doublon, reçus numérotés sans trou.

## Diagnostic (runs CI sur auto/developpement, PHP 8.2.35)
- Le noyau montre un **segfault du binaire PHP** (`php8.2 segfault at 8`, deux adresses récurrentes)
  pendant la rafale. Ce n'est pas une exception de l'application : le processus PHP meurt.
- Observé avec le mode `PHP_CLI_SERVER_WORKERS=8` **et** avec 8 serveurs `php -S` indépendants,
  avec ou sans préchauffage du cache. Échec aléatoire : 3 réussites, 4 échecs sur 7 runs.
- Dans tous les cas, l'intégrité est respectée : aucun doublon, reçus numérotés sans trou (R-33, R-137).

## Modifications conservées dans le script (sans affaiblir le contrôle final)
- Diagnostic : codes curl, journal du serveur, processus PHP, erreurs PHP, messages du noyau.
- Renvoi avec la même clé d'idempotence sur coupure réseau (comportement du téléphone, R-137).
- 8 serveurs indépendants et cache préchauffé.

## Statut
- **Étape 0 non terminée** : la CI reste rouge par intermittence.
- PHPUnit (115 tests) et Flutter : verts en PHP 8.2.

## Prochaine piste
- Exécuter la rafale sur **PHP-FPM** (le mode de la production) au lieu du serveur de développement :
  si FPM ne plante pas, le problème est limité au serveur de développement ; s'il plante aussi,
  obtenir une pile d'appels (gdb) pour identifier l'extension ou le code en cause.
