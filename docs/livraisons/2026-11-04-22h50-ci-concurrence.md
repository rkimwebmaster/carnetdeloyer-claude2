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

## Cause trouvée (5 novembre)
- Pile d'appels gdb des plantages : `zend_check_user_type_slow` appelé depuis `opcache.so`,
  c'est-à-dire le **JIT d'OPcache** (`opcache.jit=1235`, activé par la CI).
- PHP-FPM + nginx (mode production) plante aussi ; le test de bout en bout aussi, sans concurrence.
- JIT désactivé, OPcache actif : aucun plantage. Décision : `docs/decisions/2026-11-05-jit-opcache-php82.md`.

## Statut
- **Étape 0 terminée** : test de concurrence sous PHP-FPM + nginx, JIT désactivé ; test de bout
  en bout avec JIT désactivé. Résultats des runs dans AVANCEMENT.md.
- **Action pour la production** : vérifier que `opcache.jit` est désactivé sur le serveur PHP 8.2.
