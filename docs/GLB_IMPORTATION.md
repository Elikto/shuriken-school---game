# Chargement optionnel des héros Blender GLB

Le jeu peut désormais afficher **les GLB Blender riggés** si leurs fichiers sont disponibles dans `game/assets/characters/`. `hero_models.gd` privilégie `eizan.glb`, `okuni.glb` et `jimmy.glb` et démarre leur animation `Idle` importée. Sans ces fichiers, il utilise **automatiquement** les anciens modèles créés par `art.gd`, pour que la version source reste jouable.

Dans l'état présent, le système de combat et la sélection des héros fonctionnent avec les deux formats, mais **les animations spécifiques de combat/déplacement sont encore procédurales sur les anciens personnages**. Les GLB importés jouent pour le moment l'animation de repos ; le raccord avec les contrôles complets du squelette devra être ajouté.

Les GLB ne sont pas copiés depuis la série. Ils sont créés par `tools/blender/generate_heroes.py` dans GitHub Actions, et téléchargés pour les builds Windows/captures si le pipeline précédent a réussi. Ce sont toujours des maquettes préliminaires, pas le rendu final de l'illustration.
