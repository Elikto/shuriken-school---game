# Blender → Godot : modèles GLB originaux (prototype)

Le fichier `generate_heroes.py` construit de manière reproductible une première série de **véritables fichiers 3D GLB**, pour les trois héros du prototype Shuriken School, avec matériaux, mesh segmenté, groupes de poids, armature de huit os et une animation de respiration (`Idle`).

**Important :** les résultats restent des **maquettes originales non canoniques**. Ils ne correspondent pas encore à la qualité graphique de l'image conceptuelle validée. Aucune ressource du dessin animé n'est récupérée ou copiée.

## Fabrication automatique

Le workflow GitHub Actions `Blender - Modeles 3D Shuriken` installe Blender sur un runner Linux temporaire, lance le générateur, vérifie les fichiers GLB, les `skins`, les os et les clips d'animation, puis publie une archive téléchargeable nommée `Shuriken-Heros-Blender-GLB`. Le tout fonctionne **sans commande PowerShell ni installation sur ton ordinateur**.

L'artefact est une première étape avant l'import dans Godot. **Le jeu Windows utilise encore les modèles procéduraux de `game/scripts/art.gd`** : ne pas annoncer ces GLB comme déjà visibles dans le jeu.

## Prochaines validations

1. Importer l'un des GLB dans un test Godot 4.6.3 et vérifier l'armature et les clips.
2. Ajouter une couche d'adaptation d'animation pour contrôler `Skeleton3D`, sans perdre les fonctionnalités des trois héros.
3. Construire des modèles plus détaillés avec maillage continu, UV, shaders toon, expressions, costumes et proportions vérifiées par les références autorisées.
4. Tester les performances et la lisibilité des personnages sur PC puis Android.

Les problèmes d'export doivent être corrigés à partir des journaux GitHub Actions, pas masqués.
