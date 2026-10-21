# Mouvements de combat sur squelettes Blender (étape 2)

Les exports Blender/GLB intégrés aux builds Windows ne restent plus figés sur leur animation `Idle`. Le script `game/scripts/rigged_animator.gd` anime maintenant les os `Pelvis`, `Spine`, `Head`, `ArmL/R`, `LegL/R` des squelettes importés, depuis les **véritables états du gameplay** : repos, course, skateboard, saut, chute, wall-run d'Eizan, combo d'attaque, esquive.

`player.gd` trouve le `Skeleton3D` importé uniquement lorsque le GLB est présent, puis passe ses états de mouvement au nouvel animateur. Sans GLB, l'ancien moteur d'animations procédurales reste actif : le mode Godot source/offline est préservé.

`hero_models.gd` conserve l'animation de repos intégrée au GLB, sans la jouer simultanément : cela évite une double écriture sur les os à chaque frame. Les maquettes et gestes sont encore des prototypes originaux et non des reproductions certifiées du dessin animé.

La CI Blender/Godot `game/tests/glb_smoke.gd` vérifie non seulement l'existence des os et clips, mais la rotation réelle du bras droit lors d'une attaque et de la jambe gauche lors de la course et du saut. Les tests headless n'évaluent ni la qualité du timing d'animation ni la fidélité de la silhouette : comparer les captures Godot et tester en jeu reste indispensable.

**Suite du travail :** animation par interpolation plus élaborée et validation visuelle depuis le jeu, puis maillages continus, proportions, vêtements et expressions réalistes dans le style cartoon visé.
