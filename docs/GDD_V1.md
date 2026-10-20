# SHURIKEN SCHOOL — Game Design Document V1

> **Version de travail.** Concevoir une aventure coopérative aussi fidèle que possible à la série animée de 2006. Les faits du canon et les adaptations nécessaires au gameplay sont explicitement distingués.

## Résumé exécutif

Shuriken School doit donner l'impression de jouer un épisode du dessin animé, plutôt qu'un jeu de ninjas générique. Eizan Kaburagi, Okuni Dohan et Jimmy B suivent des cours improbables, découvrent des mystères et se confrontent à Katana School dans Tokirohama. Aventure, infiltration légère, énigmes et humour restent au centre du jeu. Premier épisode cible : **La furie des tongs**.

| Périmètre | Décision |
| --- | --- |
| Plateformes | Windows, Android d'abord ; iOS ensuite |
| Modes | Solo hors ligne, coop Internet à 3 joueurs |
| Forme | Action-aventure 2D, exploration, énigmes, infiltration et humour |
| Trio | Eizan, Okuni, Jimmy B |
| Statut | Conception et prototype de réseau local ; pas de jeu complet |
| Fidélité | Objectif 100 %, non vérifié sans analyse complète des épisodes |
| Distribution | Autorisations requises selon les contenus et modalités |

## 01. Règles de fidélité

Chaque élément est classé : **CONFIRMÉ** (sources primaires), **À VÉRIFIER** (sources secondaires), **ADAPTATION** (jouabilité sans prétention canonique) ou **INTERDIT SANS VALIDATION** (nouveaux pouvoirs ou contradictions avec les personnages). Priorité aux silhouettes, costumes, interactions, accessoires et ton.

Ne pas transformer la série en univers sombre, réaliste, gore ou en jeu de progression RPG déconnecté du matériau original. La cartographie exacte des écoles et de la ville, les lieux et les gestuelles devront être relevés dans les épisodes avant création des assets définitifs.

## 02. Personnages et univers

| Jouable | Référence à préserver | Rôle de gameplay proposé (ADAPTATION) |
| --- | --- | --- |
| Eizan Kaburagi | Élève motivé, rêve de ninja, règle verte | Agilité, saut mural, furtivité, attaques précises |
| Okuni Dohan | Élève studieuse, déduction, corde à sauter | Énigmes, déplacement assisté, repérage |
| Jimmy B | Skateboard, breakdance et style urbain | Mobilité, glissades et diversion |

**Secondaires :** Vlad Keitawa, Kubo Utamaro, Kita Shunai, directeur, camarades de classe et élèves rivaux, à intégrer après contrôle documentaire. Lieux : école Shuriken, école Katana, Tokirohama et environnements des épisodes.

## 03. Campagne

La progression prend la forme d'**affaires de l'école** jouables depuis un espace central. Elle n'impose pas un nouvel arc présenté comme une suite officielle. L'ordre de jeu n'est pas nécessairement l'ordre de diffusion.

| Niveau | Intrigue de référence | Systèmes proposés |
| --- | --- | --- |
| La furie des tongs | Vol des Tongs de Tokiro | Recherche, enquête, infiltration et poursuite |
| Un voleur à dormir debout | Affaires qui disparaissent | Déduction, suspects et indices |
| Le passé de Vlad | Diplôme d'évasion de Vlad | Épreuve, furtivité et déguisement |
| Maudit labyrinthe | Kubo perdu | Exploration, entraide, indices |
| L'ombre d'Eizan | Enlèvement de Kazumi | Sauvetage et protection |
| Ninja gagnant | Compétition de l'école | Épreuves de ninja et défis chronométrés |

**Tranche verticale La furie des tongs** (proposition de gameplay) : cours et tutoriel → vol annoncé → interrogatoires → obstacles coopératifs → infiltration chez les rivaux → récupération de l'objet → scène finale comique. Il faudra vérifier toutes les scènes face à l'épisode avant de les déclarer fidèles.

## 04. Gameplay et progression

**Boucle :** choisir une mission → briefing → exploration → énigmes et techniques complémentaires → défi final → débriefing → mission suivante.

- Mouvements cartoon : marche, saut, glissade, esquive et déplacements stylisés.
- Furtivité douce : vision des gardes, cachettes, diversion, poursuite sans violence réaliste.
- Combat accessible : interactions brèves, objets symboliques, étourdissement temporaire, timing.
- Énigmes adaptées au trio : complémentarité, chemins alternatifs possibles en solo.
- Progression par cours et apprentissages cohérents, jamais par superpouvoirs non canoniques.
- Checkpoints généreux, échecs humoristiques, objectifs simples.
- En solo, changement entre les héros et compagnons suivant les consignes.

## 05. Coopération Internet

| Système | V1 visée |
| --- | --- |
| Nombre de joueurs | 1 à 3, sans doublons de héros en campagne |
| Cross-play | PC Windows et Android ensemble ; iOS ultérieur |
| Session | Code d'invitation privé, salon et joueur hôte ou serveur |
| Progression | Sauvegarde de mission pour les joueurs présents |
| Déconnexion | Reconnexion, puis relais éventuel par IA de compagnon |
| Réseau | Synchronisation d'états, interpolation, validation serveur |
| Confidentialité | Minimum de données, invitations privées, pas de chat vocal natif |

Le prototype ENet dans `game/` **n'est pas encore de la coop Internet opérationnelle** : il faut tester NAT, latence, serveur/relais, sauvegardes et reconnectivité sur plusieurs réseaux.

## 06. Contrôles et HUD

| Action | PC | Mobile |
| --- | --- | --- |
| Déplacement | Flèches / WASD / stick | Joystick gauche |
| Saut | Espace / manette | Bouton tactile |
| Action | J / manette | Bouton contextuel |
| Technique | K / gâchette | Bouton technique |
| Changer héros solo | Tab | Portraits |
| Pause | Échap | Bouton pause |

HUD discret : objectif, portrait, alerte, action contextuelle, positions des partenaires. Interface adaptable à la taille de l'écran, sous-titres, remappage PC et volumes séparés.

## 07. Graphismes et sons

Animation 2D avec silhouettes, proportions, expressions et gestuelles fidèles aux références de la série. Effets de fumée et de vitesse légers, timing comique et lisibilité mobile. Décors scolaires et urbains, pas de réinterprétation science-fiction/réaliste. Musique créée pour le jeu dans une ambiance similaire ; utilisation de musiques, voix ou générique existants uniquement avec les droits correspondants.

## 08. Architecture technique

Godot 4.x : scènes des missions, composants de mouvement, animations spécifiques, PNJ, puzzles, dialogues, système réseau, interface et tests de cohérence.

| Module | Contenu |
| --- | --- |
| Core | Gestion des scènes et profils |
| Characters | Eizan, Okuni, Jimmy, outils et états |
| World | Missions, puzzles, PNJ, checkpoints |
| Narrative | Dialogues et références épisode |
| Multiplayer | Salon, synchronisation, reprise |
| UI | HUD adaptatif, tactiles, manette |
| QA / Lore | Tests, traçabilité canonique et cohérence |

**Objectifs techniques (non testés) :** 60 FPS PC, 30–60 FPS Android milieu de gamme, synchronisation résistante aux latences courantes.

## 09. Calendrier

| Étape | Estimation |
| --- | --- |
| Bible canonique et analyse épisodes | 2–5 semaines |
| Prototype contrôles et mouvements | 3–6 semaines |
| Mission solo complète | 6–12 semaines |
| Coopération Internet et tests multi-appareils | 6–12 semaines |
| Contenu de campagne, finition et audio | 3–9 mois |
| Vérification et distribution | 4–8 semaines |

**Ordre de grandeur total :** 4–8 mois pour un prototype solide ; 12–24 mois ou davantage pour un jeu complet. Le temps artistique et de validation des épisodes demeure important, même avec assistance IA.

## 10. Budget

- Godot : 0 € de licence moteur.
- Serveur de test : 5–30 €/mois, à ajuster selon les joueurs.
- Stockage : 0–10 €/mois.
- Art, animation, audio : variables, potentiellement postes majeurs.
- Droits de licence : inconnus, à négocier le cas échéant.

Aucun achat ou serveur n'est mis en route par la publication de ce dépôt.

## 11. Droit d'auteur et publication

Les personnages, décors, noms et œuvres musicales appartiennent à leurs ayants droit. Un fangame gratuit peut constituer une adaptation nécessitant l'autorisation des titulaires. Une sortie publique et l'utilisation d'éléments de la série devront être validées juridiquement. La présence d'un dépôt public ne vaut ni licence officielle, ni validation d'une diffusion de ressources protégées.

## 12. Critères de validation

- [ ] Les 26 épisodes et le spécial/film ont été indexés, avec scènes, dates, vêtements, outils et techniques.
- [ ] Eizan, Okuni, Jimmy et les principaux PNJ ont des fiches visuelles et comportementales validées.
- [ ] Chaque action, décor et mécanique comporte un statut CONFIRMÉ / ADAPTATION / À VÉRIFIER.
- [ ] La première mission fonctionne seul puis en trio sur Windows et Android.
- [ ] La latence, le FPS et les déconnexions ont été mesurés sur appareils réels.
- [ ] Ressources tierces et droit de publication ont été vérifiés.

## Annexe : sources de vérification

- Xilam Animation : https://xilam.com/media/shuriken-school/
- TF1+ : https://www.tf1.fr/tf1/shuriken-school
- Apple TV France : https://tv.apple.com/fr/show/shuriken-school/umc.cmc.1r6uqnirbq00a98e6jlcp8cgk
- Planète Jeunesse : https://www.planete-jeunesse.com/fiche-1213-shuriken-school.html
- Wikipédia EN : https://en.wikipedia.org/wiki/Shuriken_School

Matrice de contrôle par épisode : personnages, costumes, accessoires, dialogues, lieux, animations, gags, musique, trame et résolution. La mention « 100 % fidèle » désigne seulement la cible tant que l'examen exhaustif n'est pas réalisé.
