# Avancement (branche auto/developpement)

Ordre : 0. CI verte → 1. Auth → 2. Location → 3. Market → 4. Hôtels. Une exécution = une étape.

## 0. Prérequis
- [x] CI verte en PHP 8.2 : plantages causés par le JIT d'OPcache, désactivé (2026-11-04-22h50-ci-concurrence.md,
  décision docs/decisions/2026-11-05-jit-opcache-php82.md). CI 26331f6 : 3 jobs verts, 2 exécutions sur 2.

## 1. Auth
- [ ] 1.1 Audit de l'existant auth (API + mobile) contre R-09, R-19, R-72, R-182 : liste des écarts
- [ ] 1.2 User locataire non vérifié créé au contrat, Contact conservé (R-19, R-72, R-182)
- [ ] 1.3 Changement de numéro par OTP depuis le profil
- [ ] 1.4 Mobile : mode bailleur/locataire, bascule (barre et drawer)

## 2. Location
- [ ] à découper au démarrage de la feature

## 3. Market
- [ ] à découper au démarrage de la feature

## 4. Hôtels
- [ ] à découper au démarrage de la feature

## Questions pour le propriétaire
- Production : confirmer que `opcache.jit` est désactivé sur le serveur PHP 8.2 (voir la décision du 5 novembre).
