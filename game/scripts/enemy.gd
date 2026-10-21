extends CharacterBody3D
## Three gameplay archetypes and a multi-phase boss.
## Enemies are anonymous original placeholders, not specific characters from the show.

signal killed(enemy: CharacterBody3D, reward: int)
signal contact_attack(amount: int)
signal ranged_attack(origin: Vector3, direction: Vector3, amount: int)
signal warning_started(where: Vector3, radius: float)
signal area_attack(where: Vector3, radius: float, amount: int)

const Art = preload("res://scripts/art.gd")

var target: CharacterBody3D
var boss := false
var variant := 0
var chapter := 0
var hp := 44
var max_hp := 44
var damage := 9
var speed := 3.8
var attack_timer := 1.1
var charge_timer := 0.0
var windup_timer := 0.0
var age := 0.0
var stagger_timer := 0.0
var alive := true
var phase := 1
var visual: Node3D
var flash_timer := 0.0

func configure(is_boss: bool, to_target: CharacterBody3D, style: int = 0, in_chapter: int = 0) -> void:
    boss = is_boss
    target = to_target
    chapter = in_chapter
    variant = clampi(style, 0, 2)
    if boss:
        hp = 360 + chapter*110
        damage = 18 + chapter*3
        speed = 4.3 + chapter*0.25
    else:
        hp = [38, 85, 45][variant] + chapter*13
        damage = [8, 14, 7][variant] + chapter*2
        speed = [4.7, 2.6, 3.7][variant]
    max_hp = hp

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1
    add_to_group("foes")
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.73 if boss else (0.40 if variant == 1 else 0.32)
    capsule.height = 3.5 if boss else 2.0
    collider.position.y = 1.85 if boss else 1.05
    collider.shape = capsule
    add_child(collider)
    visual = Art.ninja(self, variant, true, boss)
    if boss:
        Art.cylinder(visual, 0.55, 0.18, "#ffd46e", Vector3(0,2.45,0))
    elif variant == 1:
        visual.scale = Vector3(1.20,1.10,1.20)
        Art.ball(visual,0.24,"#d1ad81",Vector3(0,2.45,0))
    elif variant == 2:
        Art.box(visual,Vector3(0.46,0.15,0.10),"#f9d18a",Vector3(0,1.26,-0.26))

func _physics_process(delta: float) -> void:
    if not alive or not is_instance_valid(target):
        return
    age += delta
    attack_timer = maxf(0.0, attack_timer-delta)
    charge_timer = maxf(0.0, charge_timer-delta)
    stagger_timer = maxf(0.0, stagger_timer-delta)
    flash_timer = maxf(0.0, flash_timer-delta)
    if visual:
        visual.scale.y = 1.0 + 0.07 * sin(age * 6.5)
    if target.smoke_timer > 0.0:
        _drift(Vector3.ZERO, delta)
        return
    if windup_timer > 0.0:
        windup_timer -= delta
        _drift(Vector3.ZERO, delta)
        if windup_timer <= 0.0:
            area_attack.emit(global_position, 4.5 if boss else 2.0, damage + 7)
        return
    if stagger_timer > 0.0:
        _drift(Vector3.ZERO, delta)
        return
    var delta_to: Vector3 = target.global_position - global_position
    delta_to.y = 0.0
    var distance: float = delta_to.length()
    if boss:
        var new_phase: int = 3 if hp <= max_hp/3 else (2 if hp <= max_hp*2/3 else 1)
        phase = new_phase
        if attack_timer <= 0.0 and distance < 5.0:
            attack_timer = maxf(2.1, 4.0-float(phase)*0.48)
            windup_timer = maxf(0.48, 1.18-float(phase)*0.12)
            warning_started.emit(global_position, 4.5)
            _drift(Vector3.ZERO, delta)
            return
        if fmod(age, 7.0) < delta and phase >= 2:
            charge_timer = 1.05
    elif variant == 2 and distance < 15.0 and attack_timer <= 0.0:
        attack_timer = 2.3
        ranged_attack.emit(global_position + Vector3(0,1.55,0),delta_to.normalized(),damage)
    elif distance < (2.4 if boss else 1.35) and attack_timer <= 0.0:
        attack_timer = 1.8 if variant == 1 else 1.2
        contact_attack.emit(damage)
    var heading: Vector3 = Vector3.ZERO
    if distance > (2.65 if boss else (7.4 if variant == 2 else 1.38)):
        heading = delta_to.normalized()
    elif variant == 2 and distance < 5.0:
        heading = -delta_to.normalized()
    if heading.length_squared() > 0.0:
        visual.rotation.y = atan2(-heading.x, -heading.z)
    _drift(heading * speed * (1.8 if boss and charge_timer > 0.0 else 1.0),delta)

func _drift(move: Vector3, delta: float) -> void:
    velocity.x = move_toward(velocity.x,move.x,15.0*delta)
    velocity.z = move_toward(velocity.z,move.z,15.0*delta)
    if is_on_floor():
        velocity.y = -0.1
    else:
        velocity.y -= 25.0 * delta
    move_and_slide()

func hit(amount: int) -> void:
    if not alive:
        return
    hp -= maxi(amount,0)
    stagger_timer = 0.14 if boss else 0.22
    flash_timer = 0.17
    if hp <= 0:
        alive = false
        killed.emit(self, 90 if boss else [9,16,13][variant])
        queue_free()
