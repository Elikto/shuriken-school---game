# Shuriken School — Game

## 🎮 Première mission jouable (web, v0.2)

Ouvrir **[le prototype dans `web/`](web/index.html)** : recherche d'indices, trois ninjas, gardes, mission terminable, contrôles PC et tactiles. Le dossier `web/` peut être publié sur un hébergement statique HTTPS ; GitHub ne lance pas automatiquement le jeu depuis la vue de code.

**Statut :** version solo jouable, assets vectoriels temporaires ; **coop Internet, jeu complet et fidélité visuelle 100 % non réalisés**. Voir le [guide du prototype](web/README.md).


Projet de **jeu d'action-aventure en 2D**, PC et mobile, avec coopération en ligne prévue, fondé sur une règle de production : **respecter au maximum l'univers de la série animée Shuriken School (2006)**.

> **Statut : conception + prototype technique.** Ce dépôt ne contient pas encore un jeu complet, des graphismes officiels, des missions terminées, ni un multijoueur Internet validé. La fidélité à 100 % est un **objectif**, pas une certification acquise.

## Commencer

- [Game Design Document V1](docs/GDD_V1.md) : univers, personnages, missions, gameplay, coop, contraintes et budget.
- [Feuille de route](docs/ROADMAP.md) : étapes et critères de progression.
- [Fidélité et droits](docs/FIDELITE_ET_DROITS.md) : vérification du canon et gestion des éléments protégés.
- [Prototype Godot](game/README.md) : déplacement, shurikens, cible d'entraînement, réseau local ENet (non validé sur appareils).

Pour ouvrir le prototype, importer `game/project.godot` depuis Godot 4.x compatible (configuration initiale pour Godot 4.6).

## Vision

- **Personnages principaux :** Eizan Kaburagi, Okuni Dohan et Jimmy B.
- **Plateformes :** Windows et Android d'abord ; iOS plus tard.
- **Modes visés :** solo avec changement de héros, coop Internet 1–3 joueurs, invitations privées, cross-play.
- **Ton :** cartoon, humour, école ninja, aventure et rivalité Shuriken / Katana.
- **Premier niveau cible :** *La furie des tongs* (adaptation jouable d'une intrigue existante).
- **Moteur :** Godot 4.x, sans licence moteur payante.

## État actuel

| Élément | État |
| --- | --- |
| Conception GDD | Première version écrite |
| Prototype Godot | Code source initial ajouté |
| Exécution et tests Godot | Non effectués / non confirmés |
| Coopération réseau local | Ébauche ENet, à tester |
| Coopération Internet | Non développée |
| Missions et assets fidèles | À réaliser après étude des épisodes |
| Compilation Android/iOS | Non effectuée |
| Publication officielle | Droits non obtenus |

## Remarques juridiques

L'univers, les personnages, noms, musiques, images et autres éléments de Shuriken School appartiennent à leurs ayants droit. Un projet de fans gratuit ne garantit pas un droit de reproduction ou de diffusion. Le code technique du prototype ne contient pas les ressources de la série ; toute diffusion publique des éléments protégés nécessite une vérification et, selon les usages, une autorisation.

## Organisation

```text
game/
  project.godot
  main.tscn
  game.gd
  README.md
docs/
  GDD_V1.md
  ROADMAP.md
  FIDELITE_ET_DROITS.md
```

Aucun agent Burnout, bot Discord ou serveur n'est démarré par ce dépôt.
