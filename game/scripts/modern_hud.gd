extends Control
## Hand-drawn HUD inspired by modern action games: active hero cards + action wheels.
## Decorative only, gameplay input continues through the existing Godot actions.
var world: Node3D
const WHITE := Color("#f4f5e8")
const BLUE := Color("#67aefa")
const GOLD := Color("#fac969")
const INK := Color("#12213a")
const HEROES := ["EIZAN","OKUNI","JIMMY B"]
const CONTROLS := ["ESPACE","F","CLIC","E"]
const LABELS := ["SAUT","TECHNIQUE","COMBO","COFFRE"]

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
    if world != null and is_instance_valid(world):
        queue_redraw()

func _draw() -> void:
    if size.x < 920 or size.y < 480:
        return
    var current := 0
    if world != null and is_instance_valid(world.player):
        current = world.player.hero_index
    _draw_heroes(current)
    _draw_actions()

func _draw_heroes(current: int) -> void:
    var y := size.y - 137.0
    for i in range(3):
        var x := 19.0+float(i)*110.0
        var active := i == current
        var border := GOLD if active else Color("#597aa8")
        draw_rect(Rect2(x,y,101,112),Color("#142037",0.92),true)
        draw_rect(Rect2(x,y,101,112),border,false,3.0 if active else 1.7)
        draw_circle(Vector2(x+51,y+47),27.0,["#e8b99f","#efba95","#aa765b"][i])
        draw_arc(Vector2(x+51,y+40),25,PI,TAU,19,Color("#23253b"),7.0)
        # Blue ninja collar silhouette (graphic representation, not TV character art).
        draw_rect(Rect2(x+29,y+66,45,12),BLUE,true)
        draw_string(ThemeDB.fallback_font,Vector2(x+11,y+89),HEROES[i],HORIZONTAL_ALIGNMENT_LEFT,-1,14,WHITE)
        draw_rect(Rect2(x+10,y+97,81,6),Color("#31536b"),true)
        var hp := 0.94 if active else 0.72
        draw_rect(Rect2(x+10,y+97,81.0*hp,6),Color("#61d0a1") if active else Color("#87b8dc"),true)

func _draw_actions() -> void:
    var y := size.y - 93.0
    for i in range(4):
        var x := size.x - 307.0 + float(i)*76.0
        draw_circle(Vector2(x,y),29.0,Color("#0f1c33",0.93))
        draw_arc(Vector2(x,y),30.0,0.0,TAU,38,Color("#9eceee"),2.4)
        match i:
            0:
                draw_line(Vector2(x-11,y+8),Vector2(x+8,y-11),WHITE,4.0)
                draw_line(Vector2(x-12,y+8),Vector2(x+8,y+10),WHITE,3.0)
            1:
                for k in range(4):
                    var a := float(k)*TAU/4
                    draw_circle(Vector2(x,y)+Vector2(cos(a),sin(a))*10.0,6.4,WHITE)
            2:
                draw_line(Vector2(x-15,y),Vector2(x+15,y),WHITE,3.0)
                draw_line(Vector2(x,y-15),Vector2(x,y+15),WHITE,3.0)
            3:
                draw_arc(Vector2(x,y),14,0.5,TAU*1.1,30,WHITE,4.0)
        draw_string(ThemeDB.fallback_font,Vector2(x-26,y+46),CONTROLS[i],HORIZONTAL_ALIGNMENT_LEFT,-1,12,WHITE)
        draw_string(ThemeDB.fallback_font,Vector2(x-28,y+61),LABELS[i],HORIZONTAL_ALIGNMENT_LEFT,-1,10,GOLD)
