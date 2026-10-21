# Journal de bord Shuriken School

Tableau de bord web en lecture seule, inspiré du site de suivi Burnout, mais exclusivement lié au dépôt Shuriken School.

## Sources et limites

- GitHub Actions : dernière exécution du workflow Godot sur main, vrais jobs et étapes avec statut et horodatage.
- Barre de progression : nombre d'étapes terminées parmi les étapes du dernier workflow ; ce n'est jamais l'achèvement du jeu.
- Historique : commits GitHub et tickets ouverts.
- Journal technique : statut réel des étapes GitHub Actions ; le stdout/stderr complet doit être consulté dans GitHub Actions, non inventé sur le site.
- Actualisation des étapes environ toutes les 2 minutes ; commits et tickets toutes les 10 minutes. Lors d'une erreur réseau ou d'une limite de l'API GitHub, l'écran signale explicitement le problème.
- Aucun accès à Ollama/Qwen, aux projets Burnout, ni aux secrets ; aucun bouton de contrôle de l'agent.

## Publication

Le site est dans dashboard/index.html ; aucune compilation JS n'est nécessaire.

Le workflow .github/workflows/shuriken-dashboard-pages.yml tente de publier ce dossier sur GitHub Pages. Si le déploiement échoue car Pages n'est pas activé, ouvrir le dépôt > Settings > Pages > Build and deployment > Source : GitHub Actions, puis relancer manuellement le workflow.

L'URL https://elikto.github.io/shuriken-school---game/ n'est valide que lorsque GitHub confirme une publication réussie.

## Confidentialité

Le dépôt Shuriken est public, ainsi que les données GitHub consultées. Le site est donc public et en lecture seule. Il n'inclut pas de commande PowerShell, de clef API, de journal d'agent local ni de ressources de la série protégées.

## Tableau des tâches et priorité visuelle (octobre 2026)

- Le site affiche jusqu'à **2 workflows Godot/Blender récents** avec les vraies étapes, leur état, barre de progression, horodatage de début, estimation et fin réelle **uniquement après exécution terminée**.
- Le temps estimé d'un run provient de la **médiane approximative des dernières durées des workflows réussis de même nom** ; les horodatages de fin estimés peuvent être dépassés. Les durées historiques approximatives utilisent run_started_at et updated_at et ne servent jamais d'heure de fin réelle. La fin réelle affichée est obtenue exclusivement depuis les timestamps completed_at des jobs GitHub terminés.
- Si aucun run n'est actif, la liste présente le dernier run confirmé ; elle ne déclare pas les agents IA en activité.
- Les **5 tâches graphiques suivantes** figurent dans `dashboard/roadmap.json`, avec une estimation de **jours de travail actif** (et non date de livraison automatique). Ce fichier est la source de vérité de la file de production visuelle ; mettre ses statuts à jour uniquement avec preuve.
- Actualisation environ toutes les 4 minutes pour préserver le quota d'API GitHub publique. Actualisation manuelle également disponible. L'ordre d'exécution des tâches de la feuille de route n'est pas une planification système.

## Horaires prévus et enchaînement sans attente volontaire

La feuille de route `roadmap.json` contient un premier créneau **prévu** de développement : **21 octobre 2026 à 07:18:43 heure de Paris** (prochain passage de l'automatisation ChatGPT, d'après sa cadence au moment de cette mise à jour). Ceci n'est pas un horaire de début réel. Pour les tâches 2–5, l'interface calcule une **fenêtre de début prévue avec l'heure** à partir du début initial et des durées minimales/maximales de toutes les tâches précédentes. Hypothèse de projection : 1 jour de travail actif = 1 jour calendaire, ce qui **suppose une activité ininterrompue non garantie**. Les écarts peuvent être considérables.

À la **validation documentée** d'une tâche (preuves GitHub et `status: completed`, `actual_finish_at`), la suivante devient prioritaire sans pause volontaire ; elle ne devient « en cours » que lorsqu'un agent démarre vraiment et enregistre `actual_start_at` avec un justificatif. Le site ne prétend jamais qu'un agent travaille uniquement parce que l'heure prévue est passée. Le développement ChatGPT est limité à des passages horaires, pas un processus résident sur un ordinateur.

**Enchaînement technique effectif :** GitHub Actions peut automatiquement démarrer le workflow de validation Godot lorsque le workflow Blender se termine avec succès (`workflow_run`). C'est un déclencheur réel pour vérifier l'import, produire une capture et compiler Windows, **pas** un système capable de créer automatiquement les modèles artistiques suivants. Aucun déclenchement si Blender échoue, pas de boucle infinie.
