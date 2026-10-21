# Shuriken School — GDD V2 : action 3D / hordes / boss / coffres

> Décision actée : abandon du style 2D/pixel/rétro. Caméra à la troisième personne, graphismes 3D cartoon **fidèles à l'animation comme direction à atteindre**, pas résultat acquis.

## Vision

Jouer une aventure 3D dans l'univers de Shuriken School : Eizan, Okuni et Jimmy B combattent des groupes d'adversaires en utilisant des techniques cohérentes avec leur identité, ouvrent des coffres et affrontent un boss, dans des lieux et scénarios identifiés dans la série. L'intention est une coopération 2–3 joueurs entre Windows et mobiles après validation du prototype solo.

## Boucle de gameplay

**Explorer → Vague d'adversaires → Objectif coop/intermède → Coffre → Vague suivante → Boss à phases → Récompenses et sauvegarde**.

### Mouvement

Courses, saut, esquive, attaques, changement de personnage en solo. La course sur les murs et la disparition dans un nuage de fumée **sont attestées pour Eizan par le synopsis Apple TV France**. L'implémentation technique du wall-run et la durée d'invisibilité restent des adaptations à ajuster grâce aux épisodes/timecodes, de même que double saut, glissade, escalade, utilisation des accessoires et actions spéciales. Toute action effectivement prouvée dans la série sera ajoutée à la liste des capacités canoniques ; la totalité ne peut être garantie avant examen de toutes les scènes.

### Combats

Petit combo direct, compétences d'aire et adversaires communs non graphiques. Les trois premières vagues visent 5 / 8 / 12 ennemis. Un champion géant clôt cette **arène d'entraînement provisoire non canonique** ; des profils de boss pertinents à la série devront remplacer ce substitut. Les coffres donnent pièces et soins par convention de jeu temporaire.

### Caméra, visuels, son

Caméra 3D orbitale, contrôles souris/manette en phase ultérieure, luminosité chaude, contours/toon, ombres doux, expressivité forte, animation cartoon. **Les meshes primitifs actuels ne sont pas des modèles définitifs de la série.** Ne pas employer des captures/voix/musiques d'épisodes sans les autorisations nécessaires.

### Dialogues

Écrire d'abord les objectifs et intentions propres à chaque scène, étiqueter les dialogues provisoires originaux. Confronter au déroulé canonique, demander les droits avant toute reproduction de répliques exactes. Pas de faux dialogues « officiels ».

### Coop Windows/Android

Serveur/autorité des dégâts, interpolation et prédiction, parties privées et codes d'invitation, 3 personnages distincts, système de reconnexion, reprise de session, optimisation mobile. **Non disponible dans la V0.1 3D.**

## Conditions de validation

- [ ] Le prototype Godot démarre sans erreurs, test FPS PC et Android.
- [ ] Visuels du trio et de l'école contrôlés avec les références officielles.
- [ ] Toutes les capacités portent un état CANON PROUVÉ ou ADAPTATION jusqu'à preuve contraire.
- [ ] Arène entièrement rejouable avec boss et récompenses vérifiés.
- [ ] Coop entre PC et appareil Android sur réseaux différents.
- [ ] Autorisations des ayants droit vérifiées avant exploitation publique.
