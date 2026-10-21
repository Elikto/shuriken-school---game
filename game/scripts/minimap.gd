extends Control
## A live top-down tactical minimap. No web services or external assets.
var world: Node3D
const BG := Color("#17243c")
const GOLD := Color("#f8d36c")
const RED := Color("#f26862")
const BLUE := Color("#6ebde8")

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
    if world != null and is_instance_valid(world):
        queue_redraw()

func _draw() -> void:
    var c := size * 0.5
    var radius := minf(size.x,size.y) * 0.47
    draw_circle(c,radius+5.0,Color("#fff1c9"))
    draw_circle(c,radius+1.5,BG)
    draw_circle(c,radius-5.0,Color("#d1c59d"))
    # Muted playable terrain, roads and the surrounding academy.
    for n in range(7):
        var z := float(n-3)*18.0
        draw_line(c+Vector2(-radius+13,z),c+Vector2(radius-13,z),Color("#a3b798",0.48),2.0)
        draw_line(c+Vector2(z,-radius+13),c+Vector2(z,radius-13),Color("#a3b798",0.45),2.0)
    draw_rect(Rect2(c-Vector2(34,34),Vector2(68,68)),Color("#e2cfa4"),true)
    draw_rect(Rect2(c-Vector2(30,30),Vector2(60,60)),Color("#ab9281"),false,2.0)
    draw_line(c+Vector2(0,-radius+6),c+Vector2(0,-radius+24),Color("#fff7ce"),3.0)
    if world == null or not is_instance_valid(world):
        return
    for enemy in world.foes:
        if is_instance_valid(enemy):
            _marker(c,enemy.global_position,RED,4.5 if enemy.boss else 3.4)
    for ch in world.chests:
        if is_instance_valid(ch):
            _marker(c,ch.global_position,GOLD,4.5)
    for scroll in world.scrolls:
        if is_instance_valid(scroll):
            _marker(c,scroll.global_position,BLUE,3.6)
    if is_instance_valid(world.player):
        _marker(c,world.player.global_position,Color.WHITE,7.0)
    draw_string(ThemeDB.fallback_font,c+Vector2(-5,-radius+23),"N",HORIZONTAL_ALIGNMENT_LEFT,24,16,Color("#28324b"))

func _marker(center: Vector2, pos: Vector3, color: Color, radius: float) -> void:
    var p := center + Vector2(pos.x,-pos.z) * 1.65
    if p.distance_to(center) < minf(size.x,size.y)*0.40:
        draw_circle(p,radius+1.6,Color("#15213a"))
        draw_circle(p,radius,color)
