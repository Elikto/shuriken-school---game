# Shuriken School — prototype Godot 4.6

Prototype **technique** sans graphismes, musiques ni copies des personnages protégés de la série existante.

- Déplacement 2D, cible d'entraînement, projectiles et compteur partagé.
- Coopération 1 à 4 joueurs sur **réseau local** via UDP/ENet, hôte autoritaire. Le GDD vise **3** héros canoniques pour la campagne.
- Touches fléchées sur PC ; boutons tactiles dessinés dans l'interface.
- Développement / tests en cours : exécution dans Godot, export mobile et coop Internet **non validés**.

### Ouverture

Importer `project.godot` dans l'éditeur Godot 4.x compatible, puis lancer la scène `main.tscn`.

### Limites connues

Le projet est un bac à sable réseau, pas un premier niveau « fidèle » terminé : absence de sprites officiels, de missions, de contrôle de latence, de synchronisation de scènes et de système d'invitation. La connexion Internet entre réseaux différents nécessitera serveur relais/dédié ou solution réseau adaptée, gestion de déconnexion et essais sur PC + téléphones. Pour Android, l'autorisation INTERNET doit figurer dans l'export. Pour iOS, environnement et compte Apple adaptés requis.
