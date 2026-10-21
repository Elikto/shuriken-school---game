# Direction artistique 3D — Alpha 0.4

## Référence souhaitée

La demande est un jeu d'action 3D à caméra arrière légèrement aérienne, visuel lumineux et moderne évoquant le dessin animé **Shuriken School** : trois ninjas identifiables, vêtements noir/bleu, toitures, végétation, ponts, eau, coffres, hordes et boss. L'illustration de conception validée dans la conversation est un **objectif artistique**, pas une capture du moteur ni un asset de jeu.

## Modifications effectivement intégrées

- Caméra à troisième personne plus reculée et élevée, toujours orientable.
- Cartographie : mini-carte en temps réel des adversaires, joueurs, coffres et rouleaux.
- Interface : cartes d'Eizan, Okuni, Jimmy et raccourcis de techniques.
- Monde : pavés colorés, temples et toits superposés, pont, cascade, massifs, fleurs, lanternes, accessoires d'entraînement, montagnes, proportions plus cartoon.
- Personnages : premières silhouettes noir/bleu et coiffures différenciées, règle verte, corde et skateboard, contours noirs simples, marche animée.
- Conservation des mécaniques testées : trois chapitres, trois vagues, boss, récompenses, sauvegarde, saut, course murale d'Eizan.

## Limites visibles et techniques

- Pas d'assets ou d'animations officiels provenant de la série ; ressemblance exacte **non acquise**.
- Silhouettes primitives encore très inférieures à l'image conceptuelle.
- Décor généré par de nombreux MeshInstance3D (optimisation et regroupement en MultiMesh nécessaires pour Android et scènes chargées).
- Animation de marche basique, pas de rig facial, pas de cinématiques animées ni de doublage.
- Mini-carte non occluse par la géométrie, adaptée à cette arène seulement.
- Coop Internet et APK Android stable toujours absents ; distribution publique de l'univers protégée par droits.

## Priorités de qualité graphique

1. Référencer les 26 épisodes et le spécial, capturer les planches d'apparence avec permission.
2. Construire des modèles toon stylisés par personnage en Blender : vêtements, coiffures, accessoires et proportions.
3. Rigger et animer idle, run, wall-run, double jump (si vérifié), esquive, attaques, réactions, expressions et skateboard.
4. Textures peintes à la main, contour contrôlé et éclairage cohérent avec le style officiel.
5. Décor modulaire optimisé avec LOD/occlusion et performances Windows/Android.
6. Tests visuels et de jeu sur appareil réel, puis synchronisation multijoueur.

## Validation

Les tests GitHub Actions importent la scène dans Godot 4.6.3, contrôlent les transitions de campagne et compilent un Windows ZIP contenant EXE + PCK. La capture visuelle du moteur est publiée comme artefact. La signature et l'export Android nécessitent encore correction.

**État : prototype 3D jouable rapproché de la référence, pas un jeu graphique final fidèle à 100 %.**
