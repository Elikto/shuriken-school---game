# Journal de développement — Version 0.2

## Réalisé (2026-10-21)

Un **niveau prototype jouable en solo** de `La furie des tongs` a été développé dans `web/`, sur navigateur PC et mobile :

- Contrôles flèches / WASD, E, Espace, K/J/F, personnages par 1/2/3 ou Q.
- Interface mobile avec boutons de mouvement, d'action, de compétence et de lancer.
- Eizan (rush), Okuni (repérage et déchiffrage), Jimmy (diversion).
- Trois indices ; déverrouillage par Okuni ; porte Katana ; objet final et victoire.
- Gardes, vision et alertes, poursuite, projectiles d'entraînement, dégâts et points de contrôle.
- Menus d'accueil, pause, victoire/défaite et bouton « Rejouer ».
- Sons synthétiques facultatifs, graphismes originaux temporaires.
- Manifeste et service worker PWA pour hébergement HTTPS et offline après premier chargement.

### Tests exécutés

Le script `tests/smoke.py` a été exécuté avec Chromium/Playwright : lancement, sélection des personnages, collecte des trois indices, déchiffrage restreint à Okuni, victoire, relance et pause validés. La disposition mobile et les actions tactiles simulées ont également passé. `node --check` ne signale pas d'erreur de syntaxe JS.

### Non réalisé

- **Coopération Internet** (Godot ENet du répertoire `game/` reste un prototype séparé non validé).
- Exécutable Windows natif et APK Android (pour l'instant navigateur installable via PWA sous conditions).
- Réécriture du jeu épisode par épisode et fidélité visuelle officielle « 100 % ».
- Musiques/voix/visuels de la série, licences, publication commerciale.
- Essais multiappareils et réseau de production.

### Suite prioritaire

1. Valider la bible graphique et les droits.
2. Adapter personnages et animations, dialogues référencés par épisode.
3. Ajouter les missions suivantes et sauvegarde locale.
4. Développer une architecture coop autoritaire avec synchronisation et reconnexion.
5. Tester PC + Android physiques, puis faire un packaging officiel selon autorisation.
