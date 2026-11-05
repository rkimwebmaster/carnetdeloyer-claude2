# 2026-11-05 : JIT d'OPcache désactivé en PHP 8.2

Règles concernées : R-33 (reçus sans trou), R-137 (paiements idempotents), contrainte PHP 8.2 (CLAUDE.md).

## Constat (CI GitHub, PHP 8.2.35, PHP-FPM + nginx)
- Sous une rafale de paiements simultanés, les processus PHP-FPM **plantent** (segfault).
- Pile d'appels (gdb) : `zend_check_user_type_slow` appelé depuis `opcache.so`, c'est-à-dire
  depuis le code compilé par le **JIT** (configuration de la CI : `opcache.jit=1235`, tampon 256M).
- Même plantage avec le serveur de développement `php -S`, y compris **sans concurrence** (test de
  bout en bout app ↔ API, requêtes séquentielles : « Segmentation fault »). PHPUnit n'est pas touché (CLI, sans OPcache).
- JIT désactivé (`opcache.jit=disable`, OPcache toujours actif) : aucun plantage, 30 requêtes sur 30.
- Les données sont restées intactes dans tous les cas (aucun doublon, reçus sans trou).

## Décision proposée (à valider par le propriétaire)
- **Production : JIT désactivé** tant que le serveur est en PHP 8.2.
  ```ini
  ; php.ini du serveur (SAPI fpm ou apache2)
  opcache.enable=1
  opcache.jit=disable
  ```
  Vérification : `php-fpm8.2 -i | grep opcache.jit` (ou une page `phpinfo()` temporaire).
  OPcache sans JIT garde l'essentiel du gain de performance pour une application web Symfony.
- Le test de concurrence tourne sous PHP-FPM, JIT désactivé, comme la production recommandée.
  `OPCACHE_JIT=1235 ./tests/Concurrence/encaissements-paralleles.sh` permet de reproduire le plantage.

## Suites possibles
- Si un jour le JIT est souhaité : passer à une version de PHP où ce cas ne plante plus, après
  le même test de concurrence sur cette version.
