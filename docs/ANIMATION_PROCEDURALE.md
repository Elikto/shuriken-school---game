# Animation procédurale — première passe

Une modification ciblée du prototype 3D pour remplacer les mouvements entièrement rigides par des articulations animées. Code dans `game/scripts/character_animator.gd`.

**Implémenté :** tête et torse animables ; bras et jambes indépendants ; poses différenciées idle, course, saut, chute, attaque, esquive et course murale ; posture de glisse pour Jimmy ; pigtails d'Okuni légèrement mobiles ; règle d'Eizan et corde d'Okuni attachées au pivot du bras.

**Fidélité :** il s'agit d'animations procédurales provisoires et non d'animations reproduites depuis les épisodes. Les véritables modèles riggés et les animations de référence nécessitent une production 3D dédiée et une validation juridique des sources.

**Tests :** GitHub Actions vérifie la structure des pivots, la présence des accessoires, la variation de l'angle du skate et le reste de la campagne en mode sans interface. Les conditions physiques et le rendu doivent encore être testés visuellement au clavier/manette.
