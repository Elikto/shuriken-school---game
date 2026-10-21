# Shuriken School — campagne 3D (alpha 0.3, fan-game non officiel)

**Un jeu d'action et d'exploration 3D à la troisième personne**, comprenant trois missions à débloquer successivement. Les personnages, les éléments narratifs de la série et leurs techniques restent soumis à un travail documentaire épisode par épisode ; le code actuel ne contient **aucun modèle ou enregistrement officiel**.

## Jouer sur Windows

Ouvrez l'onglet [GitHub Actions](https://github.com/Elikto/shuriken-school---game/actions/workflows/godot-validation.yml), choisissez le dernier test **vert**, puis téléchargez l'archive **ShurikenSchool3D-Windows**. Décompressez **EXE et PCK dans le même dossier** et lancez l'EXE. Ne lancez pas la source Godot si vous voulez seulement jouer.

## État des fonctionnalités

| Fonction | État alpha 0.3 |
| --- | --- |
| 3D troisième personne | Implémenté ; rendu procédural provisoire |
| Missions | Trois chapitres originaux avec repérage de trois rouleaux, vagues, coffres et boss |
| Ennemi de mêlée, garde lourd, ennemi à distance | Implémentés |
| Boss | Trois variantes avec trois phases, charge et attaque de zone annoncée |
| Héros | Eizan, Okuni, Jimmy B interchangeables en solo |
| Actions | Marche, course, saut, combo x3, esquive, techniques, course murale Eizan, camouflage fumée |
| Progression | Déblocage de mission, meilleurs scores étoilés et pièces conservées en local |
| Effets et graphismes | Décors 3D toon originaux et provisoires, aucun asset officiel |
| Coop Internet | **Pas implémentée / pas annoncée comme disponible** |
| Téléphone | Interface tactile expérimentale ; pas d'APK publié |
| Niveau « 100 % fidèle » | **Non atteint : vérification épisode par épisode à faire** |

### Commandes PC

WASD / flèches : déplacer ; souris droite : caméra ; clic gauche : attaquer (enchaîner x3) ; espace : saut et course murale d'Eizan près d'un mur ; Maj : esquive ; F : technique ; Q : héros suivant ; E : coffre ; Échap : pause.

### Compilation

Le dossier `game/` s'ouvre avec Godot 4.6.3. Sur GitHub Actions, chaque mise à jour des scripts lance import, test de gameplay sans interface et export Windows. Voir `.github/workflows/godot-validation.yml`.

## Campagne

1. **L'École Shuriken** : récupérer les rouleaux, 5/8/12 adversaires, boss du dojo.
2. **Jardins de Tokirohama** : nouveau décor, 7/10/13 adversaires, gardien du jardin.
3. **Le Portail rival** : nouvelle ambiance, 9/12/15 adversaires et boss final.

**Ces missions et lignes de dialogue sont des adaptations originales de gameplay, pas des épisodes officiels ni des répliques de la série.** Les techniques attestées sont consignées dans `docs/CANON_ET_MOUVEMENTS.md` ; la correspondance complète des 26 épisodes reste à faire.

## Licences et diffusion

Le code informatique et les objets géométriques de démonstration sont originaux, mais les noms/personnages et l'univers « Shuriken School » appartiennent à leurs ayants droit. Ne pas diffuser une adaptation reprenant les ressources et dialogues de la série sans vérifier les droits et les autorisations requises.
