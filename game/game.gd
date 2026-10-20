extends Node2D
## Prototype indépendant 2D, sans assets de la série Shuriken School.
## Hôte autoritaire ENet; PC et Android sur réseau local.

const PORT := 9174
const SPEED := 220.0
const WIDTH := 960.0
const HEIGHT := 600.0

var net_peer: ENetMultiplayerPeer
var players: Dictionary = {}
var directions: Dictionary = {}
var shurikens: Array = []
var score: int = 0
var sync_delay: float = 0.0
var touch_input: Dictionary = {"left": false, "right": false, "up": false, "down": false}

var status_label: Label
var score_label: Label
var host_button: Button
var join_button: Button
var address_input: LineEdit

func _ready() -> void:
    RenderingServer.set_default_clear_color(Color("0b1222"))
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_failed)
    multiplayer.server_disconnected.connect(_on_disconnected)
    _build_ui()
    queue_redraw()

func _build_ui() -> void:
    var canvas := CanvasLayer.new()
    add_child(canvas)
    var ui := Control.new()
    ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.add_child(ui)

    var title := Label.new()
    title.text = "SHURIKEN SCHOOL · Coop prototype"
    title.position = Vector2(23, 12)
    title.add_theme_font_size_override("font_size", 22)
    ui.add_child(title)

    status_label = Label.new()
    status_label.text = "Hors ligne · Choisir Héberger ou Rejoindre"
    status_label.position = Vector2(23, 47)
    ui.add_child(status_label)

    score_label = Label.new()
    score_label.text = "Cibles touchées : 0"
    score_label.position = Vector2(23, 75)
    ui.add_child(score_label)

    host_button = Button.new()
    host_button.text = "Héberger"
    host_button.position = Vector2(23, 105)
    host_button.size = Vector2(112, 39)
    host_button.pressed.connect(_host)
    ui.add_child(host_button)

    address_input = LineEdit.new()
    address_input.placeholder_text = "IP de l'hôte sur le réseau"
    address_input.text = "127.0.0.1"
    address_input.position = Vector2(145, 105)
    address_input.size = Vector2(185, 39)
    ui.add_child(address_input)

    join_button = Button.new()
    join_button.text = "Rejoindre"
    join_button.position = Vector2(340, 105)
    join_button.size = Vector2(113, 39)
    join_button.pressed.connect(_join)
    ui.add_child(join_button)

    var helper := Label.new()
    helper.text = "PC : flèches / WASD non configuré · Espace : shuriken"
    helper.position = Vector2(23, 150)
    ui.add_child(helper)

    var coordinates := {"left": Vector2(28, 470), "right": Vector2(148, 470), "up": Vector2(88, 415), "down": Vector2(88, 525)}
    var glyphs := {"left": "◀", "right": "▶", "up": "▲", "down": "▼"}
    for name in coordinates:
        var button := Button.new()
        button.text = glyphs[name]
        button.position = coordinates[name]
        button.size = Vector2(53, 49)
        button.button_down.connect(_set_touch.bind(name, true))
        button.button_up.connect(_set_touch.bind(name, false))
        ui.add_child(button)

    var attack := Button.new()
    attack.text = "★ Lancer"
    attack.position = Vector2(800, 508)
    attack.size = Vector2(132, 58)
    attack.pressed.connect(_throw)
    ui.add_child(attack)

func _set_touch(name: String, pressed: bool) -> void:
    touch_input[name] = pressed

func _host() -> void:
    net_peer = ENetMultiplayerPeer.new()
    if net_peer.create_server(PORT, 4) != OK:
        status_label.text = "Impossible d'héberger sur le port %s" % PORT
        return
    multiplayer.multiplayer_peer = net_peer
    players[1] = Vector2(230, 300)
    directions[1] = Vector2.ZERO
    status_label.text = "Hôte prêt · port UDP %s · jusqu'à 4 joueurs" % PORT
    host_button.disabled = true
    join_button.disabled = true

func _join() -> void:
    net_peer = ENetMultiplayerPeer.new()
    if net_peer.create_client(address_input.text.strip_edges(), PORT) != OK:
        status_label.text = "Échec de création du client"
        return
    multiplayer.multiplayer_peer = net_peer
    status_label.text = "Connexion en cours…"
    host_button.disabled = true
    join_button.disabled = true

func _on_connected() -> void:
    status_label.text = "Connecté à l'hôte · joueur #%s" % multiplayer.get_unique_id()

func _on_failed() -> void:
    status_label.text = "Connexion impossible (vérifie l'adresse et l'UDP)"
    multiplayer.multiplayer_peer = null
    host_button.disabled = false
    join_button.disabled = false

func _on_disconnected() -> void:
    status_label.text = "Hôte déconnecté"
    multiplayer.multiplayer_peer = null
    players.clear()
    shurikens.clear()
    host_button.disabled = false
    join_button.disabled = false
    queue_redraw()

func _on_peer_connected(id: int) -> void:
    if multiplayer.is_server():
        players[id] = Vector2(230 + (id % 4) * 55, 300)
        directions[id] = Vector2.ZERO

func _on_peer_disconnected(id: int) -> void:
    if multiplayer.is_server():
        players.erase(id)
        directions.erase(id)

func _current_direction() -> Vector2:
    var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    input += Vector2(int(touch_input["right"]) - int(touch_input["left"]),
                     int(touch_input["down"]) - int(touch_input["up"]))
    return input.limit_length(1.0)

func _physics_process(delta: float) -> void:
    if multiplayer.multiplayer_peer == null:
        return
    var input := _current_direction()
    if multiplayer.is_server():
        directions[1] = input
        for id in players:
            var next_position: Vector2 = players[id] + directions.get(id, Vector2.ZERO) * SPEED * delta
            players[id] = Vector2(clampf(next_position.x, 35.0, WIDTH - 35.0), clampf(next_position.y, 190.0, HEIGHT - 30.0))
        _update_shurikens(delta)
        sync_delay += delta
        if sync_delay >= 0.08:
            sync_delay = 0.0
            receive_world.rpc(players, shurikens, score)
    else:
        submit_input.rpc_id(1, input)

@rpc("any_peer", "unreliable")
func submit_input(direction: Vector2) -> void:
    if not multiplayer.is_server():
        return
    var sender := multiplayer.get_remote_sender_id()
    if players.has(sender):
        directions[sender] = direction.limit_length(1.0)

@rpc("authority", "call_local", "unreliable")
func receive_world(state_players: Dictionary, state_shurikens: Array, state_score: int) -> void:
    players = state_players
    shurikens = state_shurikens
    score = state_score
    score_label.text = "Cibles touchées : %s" % score
    queue_redraw()

func _throw() -> void:
    if multiplayer.multiplayer_peer == null:
        return
    if multiplayer.is_server():
        _create_shuriken(1)
    else:
        request_throw.rpc_id(1)

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
        _throw()

@rpc("any_peer", "reliable")
func request_throw() -> void:
    if multiplayer.is_server():
        _create_shuriken(multiplayer.get_remote_sender_id())

func _create_shuriken(player_id: int) -> void:
    if not players.has(player_id):
        return
    var direction: Vector2 = directions.get(player_id, Vector2.RIGHT)
    if direction.is_zero_approx():
        direction = Vector2.RIGHT
    shurikens.append({"position": players[player_id], "velocity": direction.normalized() * 440.0, "life": 1.2})

func _update_shurikens(delta: float) -> void:
    var next_bullets: Array = []
    for bullet in shurikens:
        bullet["position"] += bullet["velocity"] * delta
        bullet["life"] -= delta
        if bullet["position"].distance_to(Vector2(710, 310)) <= 32.0:
            score += 1
            continue
        if bullet["life"] > 0:
            next_bullets.append(bullet)
    shurikens = next_bullets

func _draw() -> void:
    draw_rect(Rect2(12, 180, 936, 405), Color("182640"), true)
    for x in range(80, 960, 100):
        draw_line(Vector2(x, 184), Vector2(x, 584), Color("233553"), 1)
    for y in range(210, 590, 100):
        draw_line(Vector2(12, y), Vector2(948, y), Color("233553"), 1)
    draw_circle(Vector2(710, 310), 30, Color("f49c6b"))
    draw_circle(Vector2(710, 310), 17, Color("663956"))
    for id in players:
        var color := Color("a48bff") if id == multiplayer.get_unique_id() else Color("66d9bc")
        draw_circle(players[id], 23, Color("263042"))
        draw_circle(players[id], 18, color)
    for bullet in shurikens:
        draw_circle(bullet["position"], 7, Color("f5e7a5"))
