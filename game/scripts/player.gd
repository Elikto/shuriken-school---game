extends CharacterBody3D

signal hit_points_changed(current: int, maximum: int)
signal attacked(strength: int, range_limit: float, facing: Vector3)
signal special_used(hero: int, center: Vector3)
signal request_interact
signal died

const Art = preload("res://scripts/art.gd")
const RUN_SPEED := 8.0
const JUMP_SPEED := 10.0
const GRAVITY := 23.0
const ATTACK_COOLDOWN := 0.35
const SKILL_COOLDOWN := 6.0

var hero_index := 0
var max_health := 120
var health := 120
var attack_timer := 0.0
var skill_timer := 0.0
var dash_timer := 0.0
var dash_invincible := 0.0
var facing := Vector3(0,0,-1)
var touch_move := Vector2.ZERO
var touch_jump := false
var enable_eizan_wall_run := true # Wall-running by Eizan is stated in the Apple TV France series synopsis.
var wall_run_left := 0.0
var smoke_timer := 0.0
var visual: Node3D
var camera: Camera3D
var camera_yaw := 0.0
var camera_pitch := 0.38
var camera_distance := 19.0
var camera_height := 8.2
var camera_sensitivity := 0.003
var _time := 0.0
var combo_count := 0
var combo_window := 0.0
var swing_time := 0.0
var knockback_resistance := 0.0

func _ready() -> void:
    add_to_group("player")
    collision_layer = 1
    collision_mask = 1
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.34
    capsule.height = 2.1
    var shape := CollisionShape3D.new()
    shape.shape = capsule
    shape.position.y = 1.1
    add_child(shape)
    visual = Node3D.new()
    add_child(visual)
    _rebuild_character()
    camera = Camera3D.new()
    camera.current = true
    camera.fov = 54
    camera.near = 0.2
    get_parent().call_deferred("add_child", camera)
    hit_points_changed.emit(health, max_health)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_yaw -= event.relative.x * camera_sensitivity
        camera_pitch = clampf(camera_pitch - event.relative.y * camera_sensitivity, -0.15, 0.78)
    if event is InputEventScreenDrag:
        camera_yaw -= event.relative.x * camera_sensitivity * 1.8
        camera_pitch = clampf(camera_pitch - event.relative.y * camera_sensitivity * 1.8, -0.15, 0.78)
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func select_hero(index: int) -> void:
    # Smoke cannot persist after switching to a different character.
    smoke_timer = 0.0
    combo_count = 0
    combo_window = 0.0
    visual.visible = true
    hero_index = posmod(index, 3)
    _rebuild_character()

func _rebuild_character() -> void:
    for n in visual.get_children():
        n.queue_free()
    Art.ninja(visual, hero_index)

func _physics_process(delta: float) -> void:
    if health <= 0:
        return
    _time += delta
    attack_timer = maxf(0, attack_timer - delta)
    combo_window = maxf(0.0, combo_window-delta)
    swing_time = maxf(0.0, swing_time-delta)
    if combo_window <= 0.0:
        combo_count = 0
    skill_timer = maxf(0, skill_timer - delta)
    dash_timer = maxf(0, dash_timer - delta)
    dash_invincible = maxf(0, dash_invincible - delta)
    smoke_timer = maxf(0.0, smoke_timer - delta)
    visual.visible = smoke_timer <= 0.0
    var axis := Input.get_vector("move_left", "move_right", "move_forward", "move_back") + touch_move
    axis = axis.limit_length(1.0)
    var heading := Vector3(axis.x, 0.0, axis.y).rotated(Vector3.UP, camera_yaw)
    if heading.length() > 0.1:
        facing = heading.normalized()
        visual.rotation.y = atan2(-facing.x, -facing.z)
    var pace := RUN_SPEED + (1.5 if hero_index == 2 else 0.0)
    if dash_timer > 0.0:
        pace *= 2.25
        heading = facing
    velocity.x = move_toward(velocity.x, heading.x * pace, delta * 48.0)
    velocity.z = move_toward(velocity.z, heading.z * pace, delta * 48.0)
    if is_on_floor():
        wall_run_left = 0.80
        if Input.is_action_just_pressed("action_jump") or touch_jump:
            velocity.y = JUMP_SPEED
    else:
        velocity.y -= GRAVITY * delta
        # Eizan running on walls is supported by the Apple TV France synopsis.
        # This implementation is a gameplay interpretation, not scene-perfect animation.
        if hero_index == 0 and enable_eizan_wall_run and wall_run_left > 0.0 and Input.is_action_pressed("action_jump") and is_on_wall():
            var normal := get_wall_normal()
            if absf(heading.dot(normal)) < 0.43 and heading.length() > 0.1:
                velocity.y = maxf(velocity.y, -1.35)
                wall_run_left -= delta
    touch_jump = false
    move_and_slide()
    if visual != null:
        visual.position.y = sin(_time * 13.0) * 0.045 if heading.length() > 0.1 and is_on_floor() else 0.0
        visual.rotation.z = lerpf(visual.rotation.z, -0.19 if swing_time > 0.0 else 0.0, clampf(delta*15.0,0,1))
        visual.rotation.x = lerpf(visual.rotation.x, 0.15 if dash_timer > 0.0 else 0.0, clampf(delta*13.0,0,1))
    _animate_character(heading.length(), delta)
    _update_camera(delta)

func _animate_character(motion: float, delta: float) -> void:
    if visual.get_child_count() == 0:
        return
    var rig: Node = visual.get_child(visual.get_child_count()-1)
    if not is_instance_valid(rig):
        return
    var stride := sin(_time * (12.0 if dash_timer <= 0.0 else 19.0)) * clampf(motion / RUN_SPEED,0.0,1.0) * 0.52
    for name in ["LegL","LegR","ArmL","ArmR"]:
        var bone := rig.get_node_or_null(name) as Node3D
        if bone == null:
            continue
        var sign := -1.0 if name.ends_with("L") else 1.0
        if name.begins_with("Arm"):
            sign *= -1.0
        bone.rotation.x = lerpf(bone.rotation.x,stride*sign,clampf(delta*13.0,0,1))

func _update_camera(delta: float) -> void:
    if camera == null or not is_instance_valid(camera) or not camera.is_inside_tree():
        return
    var aim := global_position + Vector3(0,1.65,0)
    var local_back := Vector3(0.0, sin(camera_pitch) * camera_distance + camera_height, camera_distance * cos(camera_pitch))
    var desired := aim + local_back.rotated(Vector3.UP, camera_yaw)
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(aim, desired, 1, [get_rid()])
    var hit := space.intersect_ray(query)
    if not hit.is_empty():
        desired = hit["position"] + (aim - desired).normalized() * 0.35
    camera.global_position = camera.global_position.lerp(desired, clampf(delta * 10.0,0,1)) if camera.global_position.length() > 0.001 else desired
    camera.look_at(aim, Vector3.UP)

func perform_attack() -> void:
    if attack_timer > 0.0 or health <= 0:
        return
    attack_timer = ATTACK_COOLDOWN
    combo_count = mini(3, combo_count+1)
    combo_window = 0.95
    swing_time = 0.17
    var strength: int = (19 if hero_index == 0 else 15) + (11 if combo_count == 3 else 3*(combo_count-1))
    attacked.emit(strength, 3.15 if combo_count == 3 else 2.75, facing)

func activate_smoke() -> void:
    # The synopsis mentions Eizan disappearing into smoke. 3 seconds is a game tuning choice.
    smoke_timer = 3.0
    dash_invincible = maxf(dash_invincible, 3.0)
    visual.visible = false

func perform_skill() -> void:
    if skill_timer > 0 or health <= 0:
        return
    skill_timer = SKILL_COOLDOWN
    special_used.emit(hero_index, global_position)

func dodge() -> void:
    if health <= 0:
        return
    dash_timer = 0.21
    dash_invincible = 0.35

func take_damage(amount: int) -> void:
    if health <= 0 or dash_invincible > 0.0:
        return
    health = maxi(0, health - amount)
    dash_invincible = 0.45
    hit_points_changed.emit(health,max_health)
    if health == 0:
        died.emit()

func heal(amount: int) -> void:
    health = mini(max_health, health + amount)
    hit_points_changed.emit(health,max_health)
