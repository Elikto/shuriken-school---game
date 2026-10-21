extends CharacterBody3D

signal killed(enemy: CharacterBody3D, reward: int)
signal contact_attack(amount: int)

const Art = preload("res://scripts/art.gd")

var target: CharacterBody3D
var boss := false
var hp := 44
var max_hp := 44
var damage := 9
var speed := 3.8
var attack_timer := 1.1
var charge_timer := 0.0
var age := 0.0
var alive := true
var visual: Node3D
var shadow: MeshInstance3D

func configure(is_boss: bool, to_target: CharacterBody3D) -> void:
    boss = is_boss
    target = to_target
    hp = 460 if boss else 45
    max_hp = hp
    damage = 20 if boss else 9
    speed = 4.7 if boss else 3.5

func _ready() -> void:
    collision_layer = 1
    collision_mask = 1
    add_to_group("foes")
    var collider := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.60 if boss else 0.32
    capsule.height = 3.7 if boss else 2.0
    collider.position.y = 1.9 if boss else 1.05
    collider.shape = capsule
    add_child(collider)
    visual = Art.ninja(self, 0, true, boss)
    if boss:
        var crown := Node3D.new()
        visual.add_child(crown)
        Art.cylinder(crown,0.55,0.17,"#ffd46e",Vector3(0,2.45,0))

func _physics_process(delta: float) -> void:
    if not alive or not is_instance_valid(target):
        return
    age += delta
    attack_timer = maxf(0,attack_timer-delta)
    charge_timer = maxf(0,charge_timer-delta)
    var to_player := target.global_position - global_position
    to_player.y = 0.0
    if to_player.length() > (2.25 if boss else 1.25):
        var dir := to_player.normalized()
        var actual_speed := speed * (1.9 if boss and charge_timer > 0.0 else 1.0)
        velocity.x = dir.x * actual_speed
        velocity.z = dir.z * actual_speed
        visual.rotation.y = atan2(-dir.x,-dir.z)
    else:
        velocity.x = move_toward(velocity.x,0,delta*18)
        velocity.z = move_toward(velocity.z,0,delta*18)
        if attack_timer <= 0.0:
            attack_timer = 1.65 if boss else 1.1
            contact_attack.emit(damage)
    if boss and fmod(age, 6.5) < 0.03:
        charge_timer = 0.75
    if not is_on_floor():
        velocity.y -= 25.0 * delta
    else:
        velocity.y = -0.1
    move_and_slide()
    visual.position.y = sin(age * 5.0) * 0.045

func hit(amount: int) -> void:
    if not alive:
        return
    hp -= amount
    var previous := visual.scale
    visual.scale = previous * 1.035
    if hp <= 0:
        alive = false
        killed.emit(self, 65 if boss else 8)
        queue_free()
