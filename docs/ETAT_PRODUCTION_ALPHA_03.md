# Livraison alpha 0.3 — journal de production

**21 octobre 2026** — Passage du prototype d'une arène isolée à une campagne de 3 missions jouables en solo. Le contenu est encore provisoire et ne prétend pas reproduire intégralement la série animée.

### Livré

- Trois environnements procéduraux originaux : cour du dojo, jardins de bambous, portail rival.
- Objectif d'exploration : ramasser trois rouleaux avant les affrontements dans chaque mission.
- Trois vagues puis boss par chapitre, ennemis légers, lourds et à distance, projectiles visibles.
- Boss à trois phases, attaques de zone annoncées et charges.
- Coffres, pièces, soins, progression d'attaque, combos et esquive.
- Héros interchangeables et techniques distinctes ; Eizan : course murale / fumée (mécaniques inspirées d'un descriptif de la série).
- Progression locale sauvegardée `user://shuriken_school_campaign_v1.json` (missions ouvertes, étoiles, pièces) ; aucune donnée envoyée vers Internet.
- GitHub Actions : import Godot, scénario de test sans GPU et export Windows.

### Limitations majeures avant le « vrai jeu »

1. **Fidélité graphique** : modèles temporaires géométriques originaux, pas de personnages, écoles ni animatiques 3D officiels.
2. **Univers canonique** : scénarios/voix/mouvements doivent être vérifiés épisode par épisode ; les dialogues actuels sont de transition non canonique.
3. **Coop PC + téléphone en ligne** : synchronisation d'une campagne entière, matchmaking/invitations et anti-désynchronisation non implémentés.
4. **Campagne complète** : trois missions expérimentales, pas les 26 épisodes ; scènes, dialogues, puzzles avancés et combats au niveau d'un jeu commercial encore absents.
5. **Packaging** : export Windows automatique ; APK Android/iOS et réglages accessibles à toutes les tailles d'écran non finalisés.
6. **Validation qualité** : les tests Godot headless détectent des erreurs, mais ne remplacent pas un essai visuel réel, les essais de manette, FPS, sauvegarde sur plusieurs machines, équilibrage et QA.

### Cibles de production suivantes

- Bible du canon fiable fondée sur les 26 épisodes et le spécial : techniques, personnages, cartes, apparences, scènes et répliques sourcées.
- Refonte 3D toon de haute qualité (mesh détaillé, rig et animations pour chaque héros), menus et effets vidéo aboutis.
- Campagne écrite compatible canon : actions contextualisées, puzzles, compagnons et combats variés.
- Infrastructure réseau de coopération 1 à 3 avec tests Windows + Android ; sauvegarde des sessions.
