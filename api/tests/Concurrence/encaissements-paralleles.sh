#!/usr/bin/env bash
# Test de concurrence (hors PHPUnit) : 20 encaissements simultanés sur un même
# contrat, plus 10 envois simultanés de la même clé d'idempotence.
# Vérifie : aucun montant perdu, reçus 1..N sans trou ni doublon, une seule
# création pour la clé rejouée (R-33, R-137).
# Prérequis : base "dev" migrée et référentiels chargés.
set -euo pipefail
cd "$(dirname "$0")/../.."
PORT=${PORT:-8765}
URL="http://127.0.0.1:$PORT"

TOKEN=$(php -r '
require "vendor/autoload.php";
(new Symfony\Component\Dotenv\Dotenv())->bootEnv(".env");
$k = new App\Kernel("dev", false); $k->boot(); $c = $k->getContainer();
$em = $c->get("doctrine")->getManager(); $ch = $c->get(App\Securite\Chiffreur::class);
$tel = "+2439".random_int(10000000, 99999999);
$u = new App\Entity\User($tel, $ch->empreinte($tel), "Concurrence", "C".random_int(100000, 999999));
$em->persist($u); $em->flush();
echo $c->get("lexik_jwt_authentication.jwt_manager")->create($u);
')

# Cache préchauffé (conteneur et proxys Doctrine), comme en production : sinon chaque
# serveur génère les mêmes fichiers de cache en même temps pendant la rafale.
php bin/console cache:warmup -q
JOURNAL=$(mktemp)
# 8 serveurs PHP intégrés indépendants (un processus chacun) plutôt que le mode
# PHP_CLI_SERVER_WORKERS : ce mode plante par intermittence sous rafale (segfault du
# binaire PHP observé dans le noyau, en 8.2 comme en 8.3), sans lien avec l'application.
NB_SERVEURS=8
SERVEURS=""
for i in $(seq 0 $((NB_SERVEURS - 1))); do
  php -S 127.0.0.1:$((PORT + i)) -t public >>"$JOURNAL" 2>&1 &
  SERVEURS="$SERVEURS $!"
done
url_n() { echo "http://127.0.0.1:$((PORT + $1 % NB_SERVEURS))"; }
# En cas d'échec, afficher le journal du serveur pour le diagnostic.
diagnostic() {
  echo "--- journal du serveur ---"; tail -50 "$JOURNAL"
  # Sur GitHub Actions, le résumé apparaît aussi en annotation.
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo "::error title=Concurrence::$(tail -15 "$JOURNAL" | tr '\n' ' ' | cut -c1-1500)"
  fi
}
trap 'code=$?; kill $SERVEURS 2>/dev/null; if [ $code -ne 0 ]; then diagnostic; fi' EXIT
for i in $(seq 0 $((NB_SERVEURS - 1))); do
  for _ in $(seq 1 30); do curl -s -o /dev/null "$(url_n $i)/api/v1/referentiels/devises" && break; sleep 1; done
done

H="Authorization: Bearer $TOKEN"; J="Content-Type: application/json"
UNITE=$(curl -sf -H "$H" -H "$J" -d '{"nom":"Concurrence","type":"simple","paysId":1,"categorie":"maison"}' "$URL/api/v1/proprietes" | php -r 'echo json_decode(stream_get_contents(STDIN), true)["unites"][0]["id"];')
CONTRAT=$(curl -sf -H "$H" -H "$J" -d "{\"uniteId\":$UNITE,\"locataireNom\":\"Loc\",\"loyer\":30000,\"devise\":\"USD\",\"dateDebut\":\"$(date +%Y-%m-01)\"}" "$URL/api/v1/contrats" | php -r 'echo json_decode(stream_get_contents(STDIN), true)["id"];')

uuid() { php -r 'require "vendor/autoload.php"; echo Symfony\Component\Uid\Uuid::v4();'; }
MEME=$(uuid)
# Comme le téléphone (R-137), on renvoie la même requête, avec la même clé, si la
# connexion est coupée (codes curl 52/56 observés par intermittence avec le serveur
# PHP intégré, en 8.2 comme en 8.3). Sans --fail, une réponse HTTP d'erreur n'est
# jamais renvoyée : seules les coupures réseau le sont. Le contrôle final reste strict.
REESSAI="--retry 5 --retry-all-errors --retry-delay 1"
CODES=$(mktemp)
for n in $(seq 1 20); do curl -s $REESSAI -o /dev/null -w "%{http_code}/%{exitcode} " -H "$H" -H "$J" -d "{\"montant\":1000,\"datePaiement\":\"$(date +%F)\",\"cleIdempotence\":\"$(uuid)\"}" "$(url_n $n)/api/v1/contrats/$CONTRAT/paiements" >>"$CODES" & done
for n in $(seq 21 30); do curl -s $REESSAI -o /dev/null -w "%{http_code}/%{exitcode} " -H "$H" -H "$J" -d "{\"montant\":1000,\"datePaiement\":\"$(date +%F)\",\"cleIdempotence\":\"$MEME\"}" "$(url_n $n)/api/v1/contrats/$CONTRAT/paiements" >>"$CODES" & done
for p in $(jobs -p); do case " $SERVEURS " in *" $p "*) ;; *) wait "$p" 2>/dev/null || true ;; esac; done
cat "$CODES"; echo
echo "--- journal du serveur (fin) ---"; tail -40 "$JOURNAL"; echo "--- fin du journal ---"
# Diagnostic PHP 8.2 : processus du serveur encore vivants, erreurs PHP, plantages noyau.
php -v | head -1
echo "--- processus php -S ---"; ps -eo pid,ppid,stat,etime,cmd | grep "[p]hp .*-S" || true
echo "--- requête séquentielle après la rafale ---"; curl -sS -o /dev/null -w "%{http_code}/%{exitcode}\n" -H "$H" "$URL/api/v1/contrats/$CONTRAT" || true
echo "--- erreurs PHP ---"; tail -40 /tmp/cdl-php-erreurs.log 2>/dev/null || echo "(aucune)"
echo "--- noyau ---"; (sudo -n dmesg 2>/dev/null || dmesg 2>/dev/null) | grep -iE "segfault|php|killed" | tail -10 || true
[ -n "${GITHUB_ACTIONS:-}" ] && echo "::notice title=Codes HTTP::$(cat "$CODES")"
sleep 1

php -r '
require "vendor/autoload.php";
(new Symfony\Component\Dotenv\Dotenv())->bootEnv(".env");
$k = new App\Kernel("dev", false); $k->boot();
$db = $k->getContainer()->get("doctrine")->getConnection();
$c = (int) $argv[1];
$p = $db->fetchAssociative("SELECT COUNT(*) n, SUM(montant) total FROM paiement WHERE contrat_id = ?", [$c]);
$r = $db->fetchAssociative("SELECT COUNT(*) n, MIN(sequence) mi, MAX(sequence) ma, COUNT(DISTINCT sequence) d FROM recu r JOIN paiement p ON p.id = r.paiement_id WHERE p.contrat_id = ?", [$c]);
$e = (int) $db->fetchOne("SELECT SUM(montant_paye) FROM echeance WHERE contrat_id = ?", [$c]);
printf("paiements=%d total=%d impute=%d recus=%d sequence=%d..%d distincts=%d\n", $p["n"], $p["total"], $e, $r["n"], $r["mi"], $r["ma"], $r["d"]);
$ok = 21 === (int) $p["n"] && 21000 === (int) $p["total"] && 21000 === $e && 21 === (int) $r["n"] && 1 === (int) $r["mi"] && 21 === (int) $r["ma"] && 21 === (int) $r["d"];
echo $ok ? "OK\n" : "ECHEC\n";
if (!$ok && getenv("GITHUB_ACTIONS")) { printf("::error title=Résultat::paiements=%d total=%d impute=%d recus=%d\n", $p["n"], $p["total"], $e, $r["n"]); }
exit($ok ? 0 : 1);
' "$CONTRAT"
