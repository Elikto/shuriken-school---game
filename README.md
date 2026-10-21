# Shuriken School — Action 3D à la troisième personne

**Nouvelle orientation (octobre 2026)** : le prototype rétro/2D a été supprimé de `main` et remplacé par la base d'un **jeu 3D cartoon** Godot. Référentiel : série d'animation Shuriken School. **Projet de fan non officiel**.

## La nouvelle base 3D

Ouvrir **[`game/project.godot`](game/project.godot)** dans Godot 4.6.3 pour lancer une arène 3D expérimentale, avec caméra arrière orbitale et déplacement libre, trois vagues d'ennemis, compétences de prototype, coffres, récompenses, puis boss final. Les touches et limitations sont indiquées dans [`game/README.md`](game/README.md).

**À ne pas confondre avec un jeu terminé** : code fourni, mais la version n'a pas été exécutée/validée dans Godot lors de ce commit. La coopération en ligne PC/Android, la qualité « jeu commercial », les animations officielles, la reconstitution du dessin animé et les exports Windows/Android sont encore à faire. Les personnages sont représentés par des formes 3D originales provisoires sans modèles sous licence.

## Respect du dessin animé

- [Registre des actions, mouvements et dialogues](docs/CANON_ET_MOUVEMENTS.md) : une compétence n'est pas déclarée canonique sans source/épisode/timecode.
- [Game Design Document V2 — 3D, hordes et boss](docs/GDD_V2_3D.md).
- [Feuille de route 3D](docs/ROADMAP_3D.md).
- [Droits et fidélité](docs/FIDELITE_ET_DROITS.md).

Le **wall-run** est présent à titre de **test de gameplay non confirmé par la série**, activable/désactivable dans `game/scripts/player.gd`. Aucune réplique originale n'a été intégrée sans autorisation ni vérification.

## Commandes PC

WASD / flèches = déplacement, clic droit + souris = caméra, clic gauche = attaque, Espace = saut, Maj = esquive, F = compétence, Q = alterner les personnages, E = ouvrir un coffre, Échap = relâcher la souris/pause.

## État

| Lot | État |
|---|---|
| Ancienne version 2D/rétro | Supprimée des fichiers de `main` (reste dans l'historique Git) |
| Gameplay 3D troisième personne | Implémenté, **non validé en moteur** |
| 3 vagues, boss, coffres, soins | Implémentés, **non validés en moteur** |
| Décor toon original | Prototypé, **non fidèle aux assets officiels** |
| Mouvements + dialogues exacts dessin animé | Recherche épisode par épisode en attente |
| Coop Internet PC/mobile | Non implémentée |
| Exécutables Windows / APK Android | Non créés |

Aucun agent local, aucune dépense cloud ni service extérieur n'a été lancé par ce dépôt.
