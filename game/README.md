# Shuriken School — Prototype 3D à la troisième personne

**Changement complet de direction :** l'ancien jeu rétro/2D navigateur est supprimé de la branche principale. Ce dossier est un **prototype 3D Godot 4.6.3** (Windows/Android ciblés), avec silhouettes géométriques originales provisoires et rendu cartoon toon.

## Contenu jouable (prototype)

- Caméra 3e personne orbitale, déplacement WASD, saut, esquive, attaque de mêlée, technique spéciale.
- Trois personnages *identifiés par leur nom*, alternance solo (Eizan, Okuni, Jimmy), silhouettes **non canoniques** et remplaçables.
- Trois vagues d'adversaires (5 + 8 + 12), champion/boss et barre de santé.
- Coffre à ouvrir entre les vagues (pièces et récupération de santé).
- Arène 3D procédurale inspirée de codes visuels de l'animation (lumière, lanternes, toits stylisés, cerisiers, portails), **pas de décor authentifié de la série**.
- Contrôles tactiles provisoires et interface PC/mobile.
- Course murale réservée à Eizan et fumée d'invisibilité **attestées dans le synopsis Apple TV France** ; leur mise en scène/animation précise reste à vérifier avec les épisodes.

## Lancer

Importer `project.godot` dans Godot **4.6.3**, cliquer sur Exécuter la scène principale. Cette copie contient le projet source, **pas** d'EXE Windows ni d'APK Android compilés.

### Clavier / souris

| Action | Contrôle |
| --- | --- |
| Déplacement | WASD / flèches |
| Tourner la caméra | Clic droit pour capturer la souris, puis souris |
| Attaquer | Clic gauche |
| Sauter | Espace |
| Esquiver | Maj gauche |
| Technique | F |
| Changer de héros | Q |
| Coffre | E |
| Libérer la souris | Échap |

### Limites et honnêteté

La coopération en ligne PC/mobile est un **objectif**, non implémenté dans ce prototype. Pas d'assets, voix ou musiques extraits de la série. Aucun scan exhaustif des épisodes n'a été réalisé : on ne peut pas affirmer que toutes les actions ou dialogues du dessin animé sont reproduits. Le niveau est une arène d'entraînement **originale**, pas encore une adaptation canonique d'un épisode. Il reste aussi à valider le fonctionnement du projet dans Godot / export sur le matériel cible.

Voir `docs/CANON_ET_MOUVEMENTS.md` et `docs/ROADMAP_3D.md` avant d'ajouter une technique ou un dialogue.
