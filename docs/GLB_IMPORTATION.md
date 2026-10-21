# Chargement optionnel des héros Blender GLB

Le jeu peut désormais afficher **les GLB Blender riggés** si leurs fichiers sont disponibles dans `game/assets/characters/`. `hero_models.gd` privilégie `eizan.glb`, `okuni.glb` et `jimmy.glb` et démarre leur animation `Idle` importée. Sans ces fichiers, il utilise **automatiquement** les anciens modèles créés par `art.gd`, pour que la version source reste jouable.

Dans l'état présent, le système de combat et la sélection des héros fonctionnent avec les deux formats, mais **les animations spécifiques de combat/déplacement sont encore procédurales sur les anciens personnages**. Les GLB importés jouent pour le moment l'animation de repos ; le raccord avec les contrôles complets du squelette devra être ajouté.

Les GLB ne sont pas copiés depuis la série. Ils sont créés par `tools/blender/generate_heroes.py` dans GitHub Actions, et téléchargés pour les builds Windows/captures si le pipeline précédent a réussi. Ce sont toujours des maquettes préliminaires, pas le rendu final de l'illustration.

## Résultat vérifié le 21 octobre 2026

- **Blender → GLB : réussi** — génération des trois maquettes, un squelette chacune, animations de repos et contrôle des fichiers glTF.
- **GLB → Godot 4.6.3 : réussi** — import, huit os attendus et AnimationPlayer reconnus pour les trois personnages. [Pipeline modèles](https://github.com/Elikto/shuriken-school---game/actions/runs/39541141875).
- **Compilation Windows utilisant les GLB : réussie** — les maquettes sont récupérées depuis le dernier artefact Blender validé, importées pour l'export et chargées via `hero_models.gd` avec repli procédural. [Pipeline Godot](https://github.com/Elikto/shuriken-school---game/actions/runs/39541343039).
- **Capture réelle du moteur : réussie** dans cette exécution. Le rendu reste inférieur au concept 3D souhaité.
- **Reste à faire :** commande des os importés par les actions en jeu, véritables meshes continus, textures et coiffures fidèles, expressions et animations complètes, optimisation Android. L'APK Android n'a pas été testé dans cette exécution.
