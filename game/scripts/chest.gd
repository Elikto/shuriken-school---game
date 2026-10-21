extends Node3D

signal opened(chest: Node3D)
const Art = preload("res://scripts/art.gd")

var claimed := false
var model: Node3D
var twinkle := 0.0

func _ready() -> void:
    model = Art.chest(self)
    var area := Area3D.new()
    add_child(area)
    var col := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 1.3
    col.shape = shape
    col.position.y = 0.8
    area.add_child(col)

func _process(delta: float) -> void:
    twinkle += delta
    if not claimed:
        model.rotation.y = sin(twinkle*0.65)*0.09

func claim() -> bool:
    if claimed:
        return false
    claimed = true
    model.rotation.z = -0.13
    model.position.y = 0.1
    opened.emit(self)
    return true
