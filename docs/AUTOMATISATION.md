# Automatisation bornée — Shuriken School

## Ce qui tourne réellement

| Processus | Fréquence / déclencheur | Rôle | Limites |
|---|---|---|---|
| ChatGPT tâche planifiée | Chaque heure, si la fonctionnalité est disponible | Réexaminer le dépôt et tenter une amélioration réalisable avec les connecteurs accessibles | **Pas de processus GPU constant**, pas d'accès direct au PC Windows, pas de paiement automatique |
| GitHub Actions — vérification Godot | Chaque commit sur `main` touchant `game/**` ; également toutes les six heures | Import, test de gameplay, lancement court et diagnostic | L'ordonnanceur GitHub peut retarder un déclenchement |
| GitHub Actions — Windows | Sur modification ou déclenchement manuel, après tests | Construire EXE et PCK, publier l'archive 30 jours | Ne reconstruit pas inutilement la même archive à chaque ronde planifiée |
| GitHub Actions — capture | Sur modification ou déclenchement manuel | Capturer le vrai rendu Godot avec Xvfb | Ne garantit pas FPS sur PC/Android |
| GitHub Actions — Android | **Déclenchement manuel uniquement** | Corriger progressivement l'APK | L'export est en échec et consommait des minutes sans résultat |
| Blender / autres logiciels | Pas encore installés ni reliés au poste utilisateur via ce canal | Futur pipeline géométrie + rig + export glTF | Nécessite mise en place et validation, ne se crée pas automatiquement dans ChatGPT |

## Coûts et sécurité

- Aucun engagement de dépense récurrente ni forfait cloud : budget automatique 0 €.
- Les GitHub Actions utilisent les ressources disponibles sur le compte GitHub ; les limites et coûts éventuels sont fixés par l'offre GitHub et doivent être contrôlés sur le compte.
- Ne jamais activer en boucle des appels API IA facturables sans plafond, ni des runners self-hosted avec accès complet au PC.
- Les fichiers de la série sont protégés ; conserver les répliques, modèles et vidéos officiels hors du dépôt public sans autorisation.

## Revue

La création des meshes de qualité comparable à l'illustration conceptuelle demande du travail artistique réel. Une IA peut automatiser des outils, préparer les bases et générer des variantes, mais **l'identité graphique, le rigging, les expressions et le contrôle qualité** ne sont pas obtenus par une simple compilation Godot.

L'ordre d'exécution recommandé des prochains cycles se trouve dans les issues GitHub.
