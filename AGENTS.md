# AGENTS.md — Instructions pour les agents IA intervenant sur Shuriken School

## Mission
Développer le **vrai jeu 3D solo puis coop PC/Android** dans `Elikto/shuriken-school---game`, basé sur le dessin animé Shuriken School. Le rendu visuel visé est un dessin animé moderne en 3D : caméra arrière aérienne, personnages et costumes fidèles, décors soignés et jouables, animation expressive, hordes/ennemis, coffres, phases de boss.

Ne jamais présenter un rendu conceptuel IA comme une capture du jeu. Les captures du vrai moteur sont fournies par le workflow GitHub.

## Directives d'autonomie
- Chaque intervention doit être **petite, testable, vérifiable et annulable** ; sélectionner une seule priorité à la fois.
- Commencer par les [issues GitHub](https://github.com/Elikto/shuriken-school---game/issues) ouvertes et par l'état de GitHub Actions.
- Travailler de préférence sur une branche et une pull request pour les changements importants, et décrire les tests réellement réalisés.
- Ne pas désactiver un test pour rendre la CI verte. En cas de panne Android, préserver la compilation Windows et isoler le problème.
- Les ressources 3D/animations ne sont pas substituables par une illustration fixe ou une vidéo. Ajouter de vrais meshes importables, rigs et animations utilisables dans le moteur.
- Conserver l'expérience solo hors ligne. L'activation future de la coop se fait avec tests d'intégration.

## Accès et limites
- Aucun accès présumé au PC de l'utilisateur. Ne pas tenter de contacter localhost Ollama ni de démarrer des tâches locales.
- **Ne toucher à aucun autre dépôt**, notamment aucun projet Burnout.
- **Budget automatique = 0 €** : ne déclencher aucun service cloud IA payant, nouvelle machine, hébergement, abonnement ou API facturable sans autorisation explicite.
- Ne pas stocker de secrets, tokens ou clés API dans le dépôt ou dans les logs.
- Ne pas télécharger ni republier d'éléments protégés provenant de la série sans preuve d'autorisation. Utiliser des maquettes originales, documentées comme temporaires. Vérifier les techniques et dialogues épisode par épisode.

## Stack et tests
- **Godot 4.6.3**, GDScript. Code : `game/scripts/`. Fichiers Godot : `game/`.
- Campagne actuelle : trois missions solo, sauvegardes, bosses et objets ; **coop non opérationnelle**.
- Tester chaque changement par `game/tests/smoke.gd` et GitHub Actions. Les commandes sont exécutées dans la CI, **pas demandées à l'utilisateur**.
- Une réussite headless valide l'import et les logiques couvertes, pas la qualité visuelle, les performances mobiles ni l'absence de bugs en partie réelle.
- Avant de qualifier « joli », regarder la capture **réelle** GitHub Actions. Avant « Android prêt », vérifier un APK installable puis un test appareil. Avant « coop fonctionnelle », tester deux clients distincts.

## Priorités actuelles
1. [#1 Bible visuelle](https://github.com/Elikto/shuriken-school---game/issues/1) (références autorisées, traçabilité).
2. [#2 Pipeline Blender → Godot](https://github.com/Elikto/shuriken-school---game/issues/2) (personnages, accessoires, rig, animation).
3. [#3 Android](https://github.com/Elikto/shuriken-school---game/issues/3) (build, optimisation).
4. [#4 Coop](https://github.com/Elikto/shuriken-school---game/issues/4) (après prérequis).

## Compte rendu
À chaque amélioration livrée, indiquer : issue, commit/PR, fichiers modifiés, tests passés/échoués, capture vraie si disponible, prochaine limite. Ne jamais prétendre que la tâche continue en temps réel en dehors d'une exécution effectivement planifiée.
