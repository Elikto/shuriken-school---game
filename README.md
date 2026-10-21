# Shuriken School — Action 3D à la troisième personne

**Nouvelle orientation (octobre 2026)** : le prototype rétro/2D a été supprimé de `main` et remplacé par la base d'un **jeu 3D cartoon** Godot. Référentiel : série d'animation Shuriken School. **Projet de fan non officiel**.

## La nouvelle base 3D

Ouvrir **[`game/project.godot`](game/project.godot)** dans Godot 4.6.3 pour lancer une arène 3D expérimentale, avec caméra arrière orbitale et déplacement libre, trois vagues d'ennemis, compétences de prototype, coffres, récompenses, puis boss final. Les touches et limitations sont indiquées dans [`game/README.md`](game/README.md).

**À ne pas confondre avec un jeu terminé** : le projet a été importé et lancé **en mode headless dans Godot 4.6.3** sur GitHub Actions ; les tests de gameplay ont réussi, et un export Windows a été généré. L'apparence visuelle, les performances et les commandes n'ont pas encore été validées manuellement sur un PC/téléphone. La coopération en ligne PC/Android, la qualité « jeu commercial », les animations officielles, la reconstitution du dessin animé et l'export Android reste à faire. Un premier export Windows de démonstration est disponible ci-dessous. Les personnages sont représentés par des formes 3D originales provisoires sans modèles sous licence.

## Respect du dessin animé

- [Registre des actions, mouvements et dialogues](docs/CANON_ET_MOUVEMENTS.md) : une compétence n'est pas déclarée canonique sans source/épisode/timecode.
- [Game Design Document V2 — 3D, hordes et boss](docs/GDD_V2_3D.md).
- [Feuille de route 3D](docs/ROADMAP_3D.md).
- [Droits et fidélité](docs/FIDELITE_ET_DROITS.md).

La course sur les murs et le nuage de fumée sont **confirmés pour Eizan au niveau du synopsis Apple TV France**. Leur implémentation actuelle est une interprétation technique à recaler image par image avec l'animation originale. Aucune réplique originale n'a été intégrée sans autorisation ni vérification.

## 🎮 Télécharger et lancer la démo Windows

- **[Télécharger la démo Windows compilée (GitHub Actions)](https://github.com/Elikto/shuriken-school---game/actions/runs/39521498783/artifacts/12311380278)**.
- Le ZIP contient `ShurikenSchool3D.exe` et `ShurikenSchool3D.pck`. **Extraire les deux dans le même dossier**, puis double-cliquer sur l'EXE.
- **[Voir les tests et l'export validés](https://github.com/Elikto/shuriken-school---game/actions/runs/39521498783)**. Le premier export compile, mais reste un aperçu de mécaniques avec modèles 3D temporaires.
- Le ZIP est également fourni directement dans la conversation ChatGPT où il a été généré.

## Commandes PC

WASD / flèches = déplacement, clic droit + souris = caméra, clic gauche = attaque, Espace = saut, Maj = esquive, F = compétence, Q = alterner les personnages, E = ouvrir un coffre, Échap = relâcher la souris/pause.

## État

| Lot | État |
|---|---|
| Ancienne version 2D/rétro | Supprimée des fichiers de `main` (reste dans l'historique Git) |
| Gameplay 3D troisième personne | Import et démarrage **validés en Godot 4.6.3**, rendu visuel sur PC encore à contrôler |
| 3 vagues, boss, coffres, soins | Implémentés ; premier scénario de test automatisé **réussi**, équilibrage et partie complète à vérifier |
| Décor toon original | Prototypé, **non fidèle aux assets officiels** |
| Mouvements + dialogues exacts dessin animé | Recherche épisode par épisode en attente |
| Coop Internet PC/mobile | Non implémentée |
| APK Android | Non créé |
| Exécutable Windows | **Compilé sur GitHub Actions** : EXE + PCK dans une archive ZIP téléchargeable |

Aucun agent local Burnout ni service payant n'a été démarré. GitHub Actions effectue les contrôles et l'export Windows.
