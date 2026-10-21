extends Node3D
## Shuriken School — 3D third-person arena vertical slice.
## All geometry and dialogue are original placeholders (NOT canonical assets / scripts).

const Art = preload("res://scripts/art.gd")
const PlayerScene = preload("res://scripts/player.gd")
const EnemyScene = preload("res://scripts/enemy.gd")
const ChestScene = preload("res://scripts/chest.gd")
const Progress = preload("res://scripts/progress.gd")
const ArenaDecor = preload("res://scripts/arena_decor.gd")

const WAVE_SIZES := [5, 8, 12] # Chapter 1, retained for tests and balancing.
const CHAPTERS := [
    {"title": "L'ÉCOLE SHURIKEN", "mission": "Rassemble trois rouleaux d'entraînement.", "waves": [5,8,12], "boss": "CHAMPION DU DOJO", "sky": "#8ecadf"},
    {"title": "JARDINS DE TOKIROHAMA", "mission": "Rassemble les plans du jardin.", "waves": [7,10,13], "boss": "GARDIEN DU JARDIN", "sky": "#b6cfd0"},
    {"title": "LE PORTAIL RIVAL", "mission": "Rassemble les indices du tournoi.", "waves": [9,12,15], "boss": "MAÎTRE DES ÉPREUVES", "sky": "#e8abb4"}
]
## New dialogues below are ORIGINAL gameplay transitions, NOT lines copied from episodes.
const MISSION_DIALOGUES := [
    ["Le cours commence... Si on retrouvait les rouleaux ?", "Un peu de méthode et un peu d'agilité !", "Le champion du dojo arrive. Prépare-toi !"],
    ["La piste continue dans le jardin. Reste attentif.", "Derrière les bambous, les épreuves deviennent difficiles.", "Le gardien du jardin n'a pas dit son dernier mot !"],
    ["Nous voici près de l'école rivale. Restons ensemble.", "La compétition se complique. Utilise les trois styles !", "Dernière épreuve : défie le maître !"]
]
const HERO_NAMES := ["Eizan", "Okuni", "Jimmy B"]
const HERO_SKILLS := ["Nuage de fumée", "Onde de corde (prototype)", "Diversion (prototype)"]
const INK := Color("#122039")
const GOLD := Color("#ffe3a3")
const CREAM := Color("#fff4de")

var player
var foes: Array = []
var chests: Array = []
var wave := 0
var waiting_spawns := 0
var spawn_clock := 0.0
var active := false
var ended := false
var waiting_for_chest := false
var boss_active := false
var currency := 0
var defeated := 0
var stage_timer := 0.0
var toast_timer := 0.0
var mobile_axis := Vector2.ZERO
var overlay: Control
var hud: Control
var health_bar: ProgressBar
var boss_bar: ProgressBar
var boss_panel: PanelContainer
var wave_label: Label
var objective_label: Label
var coin_label: Label
var hero_label: Label
var timer_label: Label
var event_label: Label
var popup_title: Label
var popup_body: Label
var play_button: Button
var mode_text := "DÉMONSTRATION 3D — adaptation non officielle"
var rng := RandomNumberGenerator.new()
var selected_chapter := 0
var profile: Dictionary = {}
var session_upgrade := 0
var chapter_art: Node3D
var scrolls: Array = []
var scrolls_found := 0
var projectiles: Array = []
var warnings: Array = []
var gathering := false
var chapter_label: Label
var chapter_buttons: Array = []
var victory_ready := false
var sky_environment: Environment

func _ready() -> void:
    _install_actions()
    rng.seed = 20261021
    profile = Progress.read_profile()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _build_environment()
    _build_level()
    player = PlayerScene.new()
    player.name = "Hero"
    player.position = Vector3(0,0,6)
    add_child(player)
    player.hit_points_changed.connect(_on_health)
    player.attacked.connect(_on_attacked)
    player.special_used.connect(_on_skill)
    player.request_interact.connect(_on_interact)
    player.died.connect(_on_dead)
    player.set_physics_process(false)
    _build_interface()
    _show_menu()

func _install_actions() -> void:
    var bindings := {
        "move_forward": [KEY_W, KEY_UP], "move_back": [KEY_S, KEY_DOWN],
        "move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
        "action_jump": [KEY_SPACE], "action_dodge": [KEY_SHIFT],
        "action_skill": [KEY_F], "action_interact": [KEY_E],
        "action_switch": [KEY_Q], "action_pause": [KEY_ESCAPE]
    }
    for action in bindings:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for keycode in bindings[action]:
            var evt := InputEventKey.new()
            evt.physical_keycode = keycode
            InputMap.action_add_event(action, evt)
    if not InputMap.has_action("action_attack"):
        InputMap.add_action("action_attack")
    var click := InputEventMouseButton.new()
    click.button_index = MOUSE_BUTTON_LEFT
    InputMap.action_add_event("action_attack",click)

func _build_environment() -> void:
    var worldenv := WorldEnvironment.new()
    add_child(worldenv)
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#8ecadf")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#f8e5c3")
    env.ambient_light_energy = 0.85
    env.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    worldenv.environment = env
    sky_environment = env
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48,-32,0)
    sun.light_color = Color("#fff4d3")
    sun.light_energy = 1.3
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 70
    add_child(sun)
    var fill := DirectionalLight3D.new()
    fill.rotation_degrees = Vector3(-25,120,0)
    fill.light_color = Color("#b8d4ff")
    fill.light_energy = 0.30
    add_child(fill)

func _solid(size: Vector3, color: String, point: Vector3, collision: bool = true) -> StaticBody3D:
    var s := StaticBody3D.new()
    s.position = point
    add_child(s)
    Art.box(s,size,color)
    if collision:
        var collider := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collider.shape = shape
        s.add_child(collider)
    return s

func _build_level() -> void:
    # Wide courtyard, curved roof lines, lantern rows, framed duel area.
    _solid(Vector3(70,0.8,70),"#d6c4ab",Vector3(0,-0.5,0))
    _solid(Vector3(33,0.14,33),"#ebd7b1",Vector3(0,-0.03,0),false)
    for side in [-1,1]:
        _solid(Vector3(1.6,4.6,43),"#9e7b75",Vector3(side*22,2.1,0))
        _solid(Vector3(43,4.6,1.6),"#9e7b75",Vector3(0,2.1,side*22))
        _solid(Vector3(1.8,0.45,45),"#4d4b6c",Vector3(side*22,4.5,0),false)
        _solid(Vector3(45,0.45,1.8),"#4d4b6c",Vector3(0,4.5,side*22),false)
        for n in range(-4,5):
            var z := float(n) * 4.5
            _lantern(Vector3(side * 20.4,0,z))
    # The halls beyond the walls are backdrop only: original geometric staging.
    for offset in [-1,1]:
        var house := Node3D.new()
        house.position = Vector3(offset*28,0,-8)
        add_child(house)
        Art.box(house,Vector3(10,6,12),"#e4d5ba",Vector3(0,3,0))
        Art.box(house,Vector3(12,1.1,14),"#454866",Vector3(0,6.4,0),Vector3(0,0,0.04))
        Art.box(house,Vector3(12.5,0.32,14.6),"#e38f7b",Vector3(0,7.0,0))
        for w in [-3,0,3]:
            Art.box(house,Vector3(1.6,2.2,0.1),"#8ec3c7",Vector3(w,3,-6.1))
    _torii(Vector3(0,0,-19),1.0)
    _torii(Vector3(0,0,19),0.78)
    # Decorative training standards / paths / garden.
    for i in range(7):
        _solid(Vector3(2.1,0.07,1.15),"#fbefe0",Vector3(0,0.015,17.0-i*4.8),false)
    for i in range(14):
        var angle := TAU * float(i)/14.0
        _tree(Vector3(cos(angle)*28,0,sin(angle)*28),i)
    for i in range(18):
        var a := rng.randf_range(0,TAU)
        var distance := rng.randf_range(18,33)
        Art.ball(self,0.40,"#c7b59b",Vector3(cos(a)*distance,0.15,sin(a)*distance),Vector3(1.1,0.6,0.7))
    # Marked arena; original gameplay layout pending canon reference.
    var ring := Node3D.new()
    add_child(ring)
    for j in range(44):
        var theta := TAU*float(j)/44.0
        var stone := Art.box(ring,Vector3(1.2,0.1,0.30),"#ae9d8e",Vector3(cos(theta)*10.5,0.07,sin(theta)*10.5))
        stone.rotation.y = -theta
    # Wall runway prototype (unverified as canon).
    _solid(Vector3(0.75,3.5,7.0),"#d7b6a2",Vector3(-13.0,1.75,-7.5))
    Art.box(self,Vector3(0.12,0.10,7.0),"#efc66e",Vector3(-12.58,2.78,-7.5))

func _tree(point: Vector3, index: int) -> void:
    var node := Node3D.new()
    node.position = point
    add_child(node)
    Art.cylinder(node,0.35,4.0,"#8a5d51",Vector3(0,2.0,0),0.20)
    var pink: String = ["#ffc9d9","#ee9fba","#ffe4e8"][index%3]
    for n in range(5):
        var a := float(n)*TAU/5
        Art.ball(node,1.7,pink,Vector3(cos(a)*1.25,4.2+sin(float(n)*2.0)*0.45,sin(a)*1.25),Vector3(1.0,0.82,1.0))
    Art.ball(node,1.8,pink,Vector3(0,5.15,0))

func _lantern(point: Vector3) -> void:
    var node := Node3D.new()
    node.position = point
    add_child(node)
    Art.cylinder(node,0.09,2.0,"#5b4b5e",Vector3(0,1.0,0))
    Art.box(node,Vector3(0.73,0.85,0.73),"#ffe1a6",Vector3(0,2.18,0))
    Art.box(node,Vector3(0.95,0.18,0.95),"#9e5562",Vector3(0,2.63,0))
    Art.box(node,Vector3(0.86,0.11,0.86),"#9e5562",Vector3(0,1.7,0))

func _torii(point: Vector3, scale_v: float) -> void:
    var gate := Node3D.new()
    gate.position = point
    gate.scale = Vector3.ONE * scale_v
    add_child(gate)
    for side in [-1.0,1.0]:
        Art.cylinder(gate,0.31,6.5,"#d26461",Vector3(side*4,3.25,0))
        Art.cylinder(gate,0.45,0.33,"#434864",Vector3(side*4,6.45,0))
    Art.box(gate,Vector3(10.2,0.58,0.92),"#c65660",Vector3(0,6.17,0))
    Art.box(gate,Vector3(11.0,0.31,1.10),"#464b69",Vector3(0,6.64,0))
    Art.box(gate,Vector3(8.7,0.30,0.65),"#f4d3a5",Vector3(0,4.55,0))

func _process(delta: float) -> void:
    if not active or ended:
        return
    stage_timer += delta
    if gathering:
        _collect_scrolls()
    else:
        _update_stage(delta)
    _update_projectiles(delta)
    _update_warnings(delta)
    _update_hud()
    if toast_timer > 0:
        toast_timer -= delta
        if toast_timer <= 0:
            event_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
    if not active or ended:
        return
    if event.is_action_pressed("action_attack"):
        player.perform_attack()
    if event.is_action_pressed("action_skill"):
        player.perform_skill()
    if event.is_action_pressed("action_dodge"):
        player.dodge()
    if event.is_action_pressed("action_switch"):
        _switch_hero()
    if event.is_action_pressed("action_interact"):
        _on_interact()
    if event.is_action_pressed("action_pause"):
        _pause_game()

func _select_chapter(chapter: int) -> void:
    if chapter < 0 or chapter >= int(profile.get("unlocked", 1)):
        _toast("Cette mission n'est pas encore accessible.", 2.0)
        return
    selected_chapter = chapter
    _start()

func _apply_chapter_art() -> void:
    if is_instance_valid(chapter_art):
        chapter_art.queue_free()
    chapter_art = ArenaDecor.create(self, selected_chapter)
    sky_environment.background_color = Color(str(CHAPTERS[selected_chapter]["sky"]))

func _spawn_scrolls() -> void:
    scrolls.clear()
    scrolls_found = 0
    gathering = true
    for at in [Vector3(-9, 0, -10), Vector3(10, 0, 2), Vector3(-3, 0, 12)]:
        var scroll := Node3D.new()
        scroll.position = at
        add_child(scroll)
        Art.cylinder(scroll, 0.23, 1.25, "#ffdfa4", Vector3(0,1.12,0))
        Art.cylinder(scroll, 0.30, 0.11, "#c77d73", Vector3(0,1.7,0))
        Art.cylinder(scroll, 0.30, 0.11, "#c77d73", Vector3(0,0.53,0))
        Art.ball(scroll, 0.18, "#f9f3ca", Vector3(0,2.05,0))
        scrolls.append(scroll)

func _collect_scrolls() -> void:
    for scroll in scrolls.duplicate():
        if is_instance_valid(scroll) and scroll.global_position.distance_to(player.global_position) < 2.1:
            scrolls.erase(scroll)
            scroll.queue_free()
            scrolls_found += 1
            _toast("Rouleau récupéré ! %d/3" % scrolls_found, 1.5)
    if scrolls.is_empty() and gathering:
        gathering = false
        _toast("Mission de repérage terminée. Place aux épreuves !", 3.0)
        _next_wave()

func _start() -> void:
    active = true
    ended = false
    overlay.hide()
    hud.show()
    player.set_physics_process(true)
    player.position = Vector3(0,0,6)
    player.health = player.max_health
    player.heal(0)
    wave = 0
    defeated = 0
    currency = 0
    stage_timer = 0.0
    waiting_for_chest = false
    boss_active = false
    victory_ready = false
    session_upgrade = 0
    _apply_chapter_art()
    for scroll in scrolls:
        if is_instance_valid(scroll):
            scroll.queue_free()
    for p in projectiles:
        if is_instance_valid(p.get("mesh")):
            p["mesh"].queue_free()
    projectiles.clear()
    for w in warnings:
        if is_instance_valid(w.get("mesh")):
            w["mesh"].queue_free()
    warnings.clear()
    for f in foes:
        if is_instance_valid(f):
            f.queue_free()
    for c in chests:
        if is_instance_valid(c):
            c.queue_free()
    foes.clear()
    chests.clear()
    _spawn_scrolls()
    _toast(str(CHAPTERS[selected_chapter]["mission"]), 4.5)

func _next_wave() -> void:
    waiting_for_chest = false
    wave += 1
    if wave <= 3:
        waiting_spawns = int(CHAPTERS[selected_chapter]["waves"][wave-1])
        spawn_clock = 0.25
        boss_panel.hide()
        _toast(str(MISSION_DIALOGUES[selected_chapter][wave-1]), 4.5)
    else:
        boss_active = true
        waiting_spawns = 0
        boss_panel.show()
        _spawn_enemy(true)
        _toast("BOSS — " + str(CHAPTERS[selected_chapter]["boss"]),4.4)

func _update_stage(delta: float) -> void:
    if waiting_spawns > 0:
        spawn_clock -= delta
        if spawn_clock <= 0.0 and foes.size() < 8:
            _spawn_enemy(false)
            waiting_spawns -= 1
            spawn_clock = 0.66
    elif foes.is_empty() and not waiting_for_chest:
        if boss_active:
            _victory()
            return
        waiting_for_chest = true
        _create_chest()
        _toast("La zone est sécurisée ! Ouvre le coffre (E).",5.0)

func _spawn_enemy(is_boss: bool) -> void:
    var enemy = EnemyScene.new()
    var spawn_a := rng.randf_range(0,TAU)
    enemy.position = Vector3(cos(spawn_a)*15,0,sin(spawn_a)*15)
    var kind := (0 if is_boss else (int(defeated+waiting_spawns+selected_chapter)%3))
    enemy.configure(is_boss,player,kind,selected_chapter)
    enemy.killed.connect(_enemy_killed)
    enemy.contact_attack.connect(_enemy_contact)
    enemy.ranged_attack.connect(_enemy_ranged)
    enemy.warning_started.connect(_enemy_warning)
    enemy.area_attack.connect(_enemy_area)
    add_child(enemy)
    foes.append(enemy)

func _enemy_contact(amount: int) -> void:
    player.take_damage(amount)

func _enemy_ranged(origin: Vector3, direction: Vector3, amount: int) -> void:
    var mesh := Art.ball(self,0.25,"#f7ce82",origin)
    mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    projectiles.append({"mesh": mesh, "heading": direction.normalized(), "damage": amount, "life": 3.0})

func _enemy_warning(where: Vector3, radius: float) -> void:
    var ring := Art.cylinder(self,radius,0.05,"#e58b88",where + Vector3(0,0.035,0))
    var warning_material := StandardMaterial3D.new()
    warning_material.albedo_color = Color(0.91,0.31,0.31,0.30)
    warning_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    warning_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    ring.material_override = warning_material
    ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    warnings.append({"mesh": ring, "life": 1.10})
    _toast("⚠ Le boss prépare une attaque : esquive !",1.4)

func _enemy_area(where: Vector3, radius: float, amount: int) -> void:
    var flat: Vector3 = player.global_position - where
    flat.y = 0.0
    if flat.length() <= radius:
        player.take_damage(amount)
    for w in warnings:
        if is_instance_valid(w["mesh"]):
            w["mesh"].queue_free()
    warnings.clear()

func _update_warnings(delta: float) -> void:
    for warn in warnings.duplicate():
        warn["life"] -= delta
        if warn["life"] <= 0.0:
            if is_instance_valid(warn["mesh"]):
                warn["mesh"].queue_free()
            warnings.erase(warn)

func _update_projectiles(delta: float) -> void:
    for projectile in projectiles.duplicate():
        if not is_instance_valid(projectile["mesh"]):
            projectiles.erase(projectile)
            continue
        projectile["mesh"].position += projectile["heading"] * 12.0 * delta
        projectile["life"] -= delta
        var separation: Vector3 = projectile["mesh"].global_position - (player.global_position + Vector3(0,1.2,0))
        if separation.length() < 0.8:
            player.take_damage(int(projectile["damage"]))
            projectile["mesh"].queue_free()
            projectiles.erase(projectile)
        elif projectile["life"] <= 0.0:
            projectile["mesh"].queue_free()
            projectiles.erase(projectile)

func _enemy_killed(enemy: CharacterBody3D, reward: int) -> void:
    foes.erase(enemy)
    defeated += 1
    currency += reward
    if reward == 65:
        _toast("Le champion est vaincu !",4.0)

func _create_chest() -> void:
    var chest = ChestScene.new()
    chest.position = Vector3(-0.8,0,0)
    chest.opened.connect(_chest_opened)
    add_child(chest)
    chests.append(chest)

func _on_interact() -> void:
    if not active or ended or not waiting_for_chest:
        return
    for c in chests:
        if not is_instance_valid(c):
            continue
        if not c.claimed and player.global_position.distance_to(c.global_position) < 3.3:
            c.claim()
            return
    _toast("Approche du coffre doré pour l'ouvrir.",2.6)

func _chest_opened(_c: Node3D) -> void:
    _c.queue_free()
    chests.erase(_c)
    currency += 30
    player.heal(25)
    session_upgrade += 1
    _toast("COFFRE : +30 pièces · +25 santé · attaque +%d" % (session_upgrade*3),3.6)
    waiting_for_chest = false
    _next_wave()

func _on_attacked(strength: int, reach: float, face_dir: Vector3) -> void:
    for e in foes.duplicate():
        if not is_instance_valid(e):
            continue
        var direction: Vector3 = e.global_position - player.global_position
        direction.y = 0.0
        if direction.length() <= reach + (1.1 if e.boss else 0.0):
            if face_dir.dot(direction.normalized()) > 0.17:
                e.hit(strength + session_upgrade * 3)

func _on_skill(hero: int, center: Vector3) -> void:
    if hero == 0:
        player.activate_smoke()
        _smoke_effect(center)
    else:
        var radius := 5.5 if hero == 1 else 4.0
        var damage := 32 if hero == 1 else 42
        for e in foes.duplicate():
            if is_instance_valid(e) and e.global_position.distance_to(center) <= radius:
                e.hit(damage)
        if hero == 2:
            for e in foes:
                if is_instance_valid(e):
                    e.attack_timer = 2.0
    _toast(HERO_NAMES[hero] + " : " + HERO_SKILLS[hero],2.4)

func _smoke_effect(center: Vector3) -> void:
    for i in range(14):
        var angle := float(i) / 14.0 * TAU
        var puff := Art.ball(self, 0.4, "#e8f4f4", center + Vector3(cos(angle)*0.5,1.1,sin(angle)*0.5))
        var tween := create_tween()
        tween.set_parallel(true)
        tween.tween_property(puff, "position", puff.position + Vector3(cos(angle)*2.2, 1.7, sin(angle)*2.2), 0.85)
        tween.tween_property(puff, "scale", Vector3.ZERO, 0.85)
        tween.chain().tween_callback(puff.queue_free)

func _switch_hero() -> void:
    var selected: int = int((player.hero_index+1)%3)
    player.select_hero(selected)
    _toast("Personnage : " + HERO_NAMES[selected],1.4)

func _on_health(value: int, limit: int) -> void:
    if health_bar:
        health_bar.max_value = limit
        health_bar.value = value

func _on_dead() -> void:
    _end_game("MISSION ÉCHOUÉE","L'entraînement est terminé. Réessaie pour améliorer ton score.")

func _victory() -> void:
    var stars: int = 3 if player.health >= 75 else (2 if player.health >= 35 else 1)
    profile = Progress.finish_chapter(profile, selected_chapter, stars, currency)
    var saved: bool = Progress.write_profile(profile)
    victory_ready = true
    _end_game("MISSION TERMINÉE !", "%s\n%d étoile(s) · %d pièces · %d adversaires\nSauvegarde locale : %s" % [
        CHAPTERS[selected_chapter]["title"], stars, currency, defeated, "OK" if saved else "indisponible"
    ])
    play_button.text = "MISSION SUIVANTE" if selected_chapter < 2 else "REJOUER"
    _refresh_chapter_buttons()

func _end_game(title: String, body: String) -> void:
    ended = true
    active = false
    player.set_physics_process(false)
    for f in foes:
        if is_instance_valid(f):
            f.set_physics_process(false)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    popup_title.text = title
    popup_body.text = body
    play_button.text = "REJOUER"
    hud.hide()
    overlay.show()

func _pause_game() -> void:
    active = not active
    player.set_physics_process(active)
    for f in foes:
        if is_instance_valid(f):
            f.set_physics_process(active)
    if active:
        overlay.hide()
        hud.show()
    else:
        popup_title.text = "PAUSE"
        popup_body.text = "Reprendre l'entraînement ?"
        play_button.text = "REPRENDRE"
        overlay.show()
        hud.hide()
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _start_or_resume() -> void:
    if not active and not ended and wave > 0:
        _pause_game()
    elif victory_ready and selected_chapter < 2:
        _select_chapter(selected_chapter+1)
    else:
        _start()

func _toast(message: String, duration: float) -> void:
    toast_timer = duration
    if event_label:
        event_label.text = message

func _update_hud() -> void:
    wave_label.text = "REPÉRAGE" if gathering else ("VAGUE %d/3" % mini(wave,3) if not boss_active else "COMBAT FINAL")
    objective_label.text = ("ROULEAUX : %d/3" % scrolls_found) if gathering else ("OUVRIR LE COFFRE  [E]" if waiting_for_chest else ("VAINCRE LE BOSS" if boss_active else "VAINCRE LES ADVERSAIRES"))
    chapter_label.text = "MISSION %d/3 — %s" % [selected_chapter+1, CHAPTERS[selected_chapter]["title"]]
    coin_label.text = "✦ %d" % currency
    hero_label.text = "%s   ·   %s" % [HERO_NAMES[player.hero_index],HERO_SKILLS[player.hero_index]]
    timer_label.text = "%02d:%02d" % [int(stage_timer/60.0),int(stage_timer)%60]
    if boss_active:
        for e in foes:
            if is_instance_valid(e) and e.boss:
                boss_bar.max_value = e.max_hp
                boss_bar.value = maxi(0,e.hp)

func _style_box(bg: Color, radius: int = 16) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = bg
    style.set_corner_radius_all(radius)
    style.content_margin_left = 15
    style.content_margin_right = 15
    style.content_margin_top = 10
    style.content_margin_bottom = 10
    return style

func _label(parent: Node, caption: String, font_size: int, color: Color = CREAM) -> Label:
    var lab := Label.new()
    lab.text = caption
    lab.add_theme_color_override("font_color",color)
    lab.add_theme_font_size_override("font_size",font_size)
    parent.add_child(lab)
    return lab

func _button(parent: Node, caption: String, rect: Rect2, action: Callable) -> Button:
    var b := Button.new()
    b.text = caption
    b.position = rect.position
    b.size = rect.size
    b.add_theme_stylebox_override("normal",_style_box(Color("#e8b96d"),12))
    b.add_theme_stylebox_override("hover",_style_box(Color("#f8d58f"),12))
    b.add_theme_stylebox_override("pressed",_style_box(Color("#c99e64"),12))
    b.add_theme_color_override("font_color",INK)
    b.add_theme_font_size_override("font_size",18)
    b.pressed.connect(action)
    parent.add_child(b)
    return b

func _build_interface() -> void:
    var canvas := CanvasLayer.new()
    canvas.layer = 5
    add_child(canvas)
    hud = Control.new()
    hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.add_child(hud)

    var top_panel := PanelContainer.new()
    top_panel.add_theme_stylebox_override("panel",_style_box(Color(0.075,0.12,0.22,0.88),14))
    top_panel.position = Vector2(23,17)
    top_panel.size = Vector2(490,137)
    hud.add_child(top_panel)
    var stack := VBoxContainer.new()
    top_panel.add_child(stack)
    var title := _label(stack,"SHURIKEN SCHOOL  •  ARENA 3D",20,GOLD)
    title.add_theme_color_override("font_shadow_color",Color.BLACK)
    health_bar = ProgressBar.new()
    health_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    health_bar.custom_minimum_size = Vector2(0,14)
    health_bar.max_value = 120
    health_bar.value = 120
    health_bar.show_percentage = false
    stack.add_child(health_bar)
    hero_label = _label(stack,"Eizan  ·  Élan rapide",15)
    chapter_label = _label(stack,"MISSION 1/3",12,GOLD)
    objective_label = _label(stack,"OBJECTIF : VAINCRE LES ADVERSAIRES",12,Color("#e8cfa8"))

    var right_panel := PanelContainer.new()
    right_panel.add_theme_stylebox_override("panel",_style_box(Color(0.075,0.12,0.22,0.84),13))
    right_panel.anchor_left = 1
    right_panel.anchor_right = 1
    right_panel.offset_left = -265
    right_panel.offset_right = -23
    right_panel.offset_top = 17
    right_panel.offset_bottom = 120
    hud.add_child(right_panel)
    var right_stack := VBoxContainer.new()
    right_panel.add_child(right_stack)
    wave_label = _label(right_stack,"VAGUE 1/3",21,GOLD)
    coin_label = _label(right_stack,"✦ 0",20,CREAM)
    timer_label = _label(right_stack,"00:00",14)

    event_label = _label(hud,"",22,GOLD)
    event_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    event_label.position = Vector2(-240,165)
    event_label.custom_minimum_size = Vector2(550,45)
    event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

    boss_panel = PanelContainer.new()
    boss_panel.add_theme_stylebox_override("panel",_style_box(Color(0.13,0.06,0.19,0.9),12))
    boss_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    boss_panel.position = Vector2(-280,42)
    boss_panel.custom_minimum_size = Vector2(550,78)
    hud.add_child(boss_panel)
    var boss_stack := VBoxContainer.new()
    boss_panel.add_child(boss_stack)
    _label(boss_stack,"BOSS — TROIS PHASES DE COMBAT",15,GOLD)
    boss_bar = ProgressBar.new()
    boss_bar.show_percentage = false
    boss_bar.max_value = 460
    boss_bar.value = 460
    boss_stack.add_child(boss_bar)
    boss_panel.hide()

    var key_tips := _label(hud,"WASD  MOUVEMENT    •    SOURIS DROITE  CAMÉRA    •    CLIC  ATTAQUE    •    ESPACE  SAUT    •    MAJ  ESQUIVE    •    F  TECHNIQUE    •    Q  HÉROS    •    E  COFFRE",13)
    key_tips.anchor_top = 1
    key_tips.anchor_bottom = 1
    key_tips.offset_top = -41
    key_tips.offset_bottom = -16
    key_tips.offset_left = 24
    key_tips.offset_right = 1240
    _build_touch_buttons(hud)

    overlay = Control.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.add_child(overlay)
    var dim := ColorRect.new()
    dim.color = Color(0.035,0.06,0.11,0.88)
    dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(dim)
    var center := VBoxContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    center.position = Vector2(-335,-240)
    center.custom_minimum_size = Vector2(670,465)
    center.add_theme_constant_override("separation",24)
    overlay.add_child(center)
    var kicker := _label(center,"PROTOTYPE NON OFFICIEL · 3D TOON",15,GOLD)
    kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    popup_title = _label(center,"SHURIKEN SCHOOL",46,CREAM)
    popup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    popup_body = _label(center,"Arène d'entraînement : 3 vagues, coffres et champion.\nEizan, Okuni et Jimmy : modèles temporaires.\nLes pouvoirs et dialogues sont à valider avec les épisodes.",18,Color("#d5e0e5"))
    popup_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    popup_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    play_button = _button(center,"COMMENCER L'ENTRAÎNEMENT",Rect2(0,0,500,62),_start_or_resume)
    play_button.custom_minimum_size = Vector2(500,62)
    var chapter_hint := _label(center,"CHOISIR UNE MISSION (débloquée après victoire)",13,GOLD)
    chapter_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var chapter_row := HBoxContainer.new()
    chapter_row.alignment = BoxContainer.ALIGNMENT_CENTER
    chapter_row.add_theme_constant_override("separation",12)
    center.add_child(chapter_row)
    for i in range(3):
        var chapter_button := _button(chapter_row,"MISSION %d" % (i+1),Rect2(0,0,191,46),_select_chapter.bind(i))
        chapter_button.custom_minimum_size = Vector2(191,46)
        chapter_buttons.append(chapter_button)
    _refresh_chapter_buttons()
    var footer := _label(center,"© univers original : ayants droit de Shuriken School. Aucun asset officiel inclus.",12,Color("#e1c698"))
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    overlay.hide()

func _touch_button(parent: Control, caption: String, anchor: Vector2, pos: Vector2, cb_down: Callable, cb_up: Callable) -> void:
    var b := Button.new()
    b.text = caption
    b.anchor_left = anchor.x
    b.anchor_right = anchor.x
    b.anchor_top = anchor.y
    b.anchor_bottom = anchor.y
    b.offset_left = pos.x
    b.offset_top = pos.y
    b.offset_right = pos.x + 72
    b.offset_bottom = pos.y + 66
    b.add_theme_stylebox_override("normal",_style_box(Color(0.12,0.17,0.28,0.64),18))
    b.add_theme_stylebox_override("pressed",_style_box(Color(0.96,0.65,0.34,0.86),18))
    b.add_theme_color_override("font_color",CREAM)
    b.add_theme_font_size_override("font_size",17)
    b.button_down.connect(cb_down)
    b.button_up.connect(cb_up)
    parent.add_child(b)

func _build_touch_buttons(parent: Control) -> void:
    # Accessible during PC testing as well; built using Control for Android touch.
    _touch_button(parent,"◀",Vector2(0,1),Vector2(24,-122),func(): player.touch_move.x=-1.0,func(): player.touch_move.x=0.0)
    _touch_button(parent,"▶",Vector2(0,1),Vector2(168,-122),func(): player.touch_move.x=1.0,func(): player.touch_move.x=0.0)
    _touch_button(parent,"▲",Vector2(0,1),Vector2(96,-192),func(): player.touch_move.y=-1.0,func(): player.touch_move.y=0.0)
    _touch_button(parent,"▼",Vector2(0,1),Vector2(96,-122),func(): player.touch_move.y=1.0,func(): player.touch_move.y=0.0)
    _touch_button(parent,"⚔",Vector2(1,1),Vector2(-116,-182),func(): player.perform_attack(),func(): pass)
    _touch_button(parent,"F",Vector2(1,1),Vector2(-194,-182),func(): player.perform_skill(),func(): pass)
    _touch_button(parent,"↗",Vector2(1,1),Vector2(-116,-106),func(): player.touch_jump=true,func(): pass)
    _touch_button(parent,"Q",Vector2(1,1),Vector2(-274,-106),func(): _switch_hero(),func(): pass)
    _touch_button(parent,"E",Vector2(1,1),Vector2(-194,-106),func(): _on_interact(),func(): pass)

func _refresh_chapter_buttons() -> void:
    for i in range(chapter_buttons.size()):
        chapter_buttons[i].disabled = i >= int(profile.get("unlocked", 1))
        chapter_buttons[i].text = "%d · %s" % [i+1,"★".repeat(int(profile["best_stars"][i])) if profile["best_stars"][i] > 0 else ("OUVERT" if not chapter_buttons[i].disabled else "VERROUILLÉ")]

func _show_menu() -> void:
    popup_title.text = "SHURIKEN SCHOOL"
    popup_body.text = "Combat 3D à la troisième personne : trois vagues, coffres, puis un boss.\nPersonnages et décors originaux provisoires, non officiels.\nEizan peut courir sur les murs et disparaître en fumée (version de jeu provisoire)."
    play_button.text = "COMMENCER L'ENTRAÎNEMENT"
    hud.hide()
    overlay.show()
