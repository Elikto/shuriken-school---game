extends RefCounted
## Visual extension for the playable Godot scene.
## All meshes and patterns are generated from original procedural geometry.
const Art = preload("res://scripts/art.gd")

static func create(world: Node3D, chapter: int) -> Node3D:
    var root := Node3D.new()
    root.name = "ModernCartoonEnvironment"
    world.add_child(root)
    _courtyard_tiles(root, chapter)
    _temple(root, Vector3(0, 0, -27), 16.0, 9.0, "#f5dfb5", "#cc6453", "#333e68")
    _temple(root, Vector3(-30, 0, -14), 11.0, 6.8, "#ead9b9", "#cc6a58", "#434673")
    _temple(root, Vector3(30, 0, -14), 11.0, 6.8, "#f5e3bd", "#bf584d", "#343e6a")
    _temple(root, Vector3(-30, 0, 19), 10.0, 5.6, "#ecddbe", "#bb665c", "#3e4870")
    _temple(root, Vector3(30, 0, 19), 10.0, 5.6, "#e9d7ae", "#cf7158", "#333e68")
    _mountains(root)
    _waterfall(root, Vector3(-41,0,-22))
    _bridge(root, Vector3(-32, 0, -3))
    for i in range(10):
        var theta := float(i) * TAU / 10.0
        _shrub(root, Vector3(cos(theta)*23.5, 0.0, sin(theta)*23.5), i)
    for i in range(4):
        var x := -18.0 if i % 2 == 0 else 18.0
        var z := -16.0 if i < 2 else 15.0
        _flowering_tree(root, Vector3(x,0,z), i)
    _lanterns(root)
    _training_props(root)
    return root

static func _courtyard_tiles(root: Node3D, chapter: int) -> void:
    var tones := ["#af9680", "#c1a688", "#b59a80", "#a88d79", "#c4ae91"]
    if chapter == 1:
        tones = ["#a2a994", "#c2b99f", "#abb3a2", "#c1bca6", "#a7b09e"]
    elif chapter == 2:
        tones = ["#ac9389", "#cfb3a1", "#bba094", "#c6ab9b", "#b1a097"]
    for x in range(-9,10):
        for z in range(-9,10):
            var tone: String = tones[posmod(x * 7 + z * 11 + (x*z)%3, tones.size())]
            Art.box(root, Vector3(2.10,0.027,2.10), tone,
                Vector3(float(x)*2.16, 0.085, float(z)*2.16))
    # The courtyard is traversable; decorative stones have no physics colliders.

static func _temple(root: Node3D, origin: Vector3, width: float, height: float, wall: String, trim: String, roof: String) -> void:
    var building := Node3D.new()
    building.position = origin
    building.name = "HandbuiltDojo"
    root.add_child(building)
    Art.box(building,Vector3(width,height,9.3),wall,Vector3(0,height*0.5,0))
    Art.box(building,Vector3(width+0.3,0.35,9.55),trim,Vector3(0,0.5,0))
    for s in [-1.0,1.0]:
        Art.box(building,Vector3(0.48,height,0.5),trim,Vector3(s*(width/2.0-0.35),height*0.5,-4.7))
        Art.box(building,Vector3(0.55,0.5,10.2),trim,Vector3(s*(width/2.0+0.2),height*0.93,0))
    for i in range(3):
        var x := (float(i)-1.0)*(width/3.5)
        Art.box(building,Vector3(width*0.19,height*0.43,0.1),"#4e617b",Vector3(x,height*0.50,-4.75))
        Art.box(building,Vector3(width*0.15,height*0.37,0.12),"#9fd0c7",Vector3(x,height*0.50,-4.82))
        Art.box(building,Vector3(0.13,height*0.42,0.15),trim,Vector3(x,height*0.50,-4.95))
    # Layered tiled eaves: central ridge + pitched slabs + gold tips.
    for s in [-1.0,1.0]:
        Art.box(building,Vector3(width*0.57,0.55,11.2),roof,
            Vector3(s*width*0.27,height+1.5,0),Vector3(0,0,s*0.18))
        Art.box(building,Vector3(width*0.59,0.23,11.5),"#e8af66",
            Vector3(s*width*0.28,height+0.72,0),Vector3(0,0,s*0.18))
        for n in range(9):
            var z := float(n-4)*1.28
            Art.box(building,Vector3(width*0.55,0.055,0.07),"#526080",
                Vector3(s*width*0.28,height+1.78,z),Vector3(0,0,s*0.18))
        Art.ball(building,0.27,"#f8c575",Vector3(s*(width/2.0+0.75),height+1.37,-5.45))
        Art.ball(building,0.27,"#f8c575",Vector3(s*(width/2.0+0.75),height+1.37,5.45))
    Art.box(building,Vector3(width*0.25,0.4,11.6),roof,Vector3(0,height+2.1,0))
    Art.box(building,Vector3(width*0.27,0.15,11.8),"#f4c46e",Vector3(0,height+2.38,0))

static func _mountains(root: Node3D) -> void:
    var colors := ["#a1b9b3","#91afaa","#b0bbab","#7f9fac"]
    for n in range(7):
        var x := float(n-3)*17.0
        var rock := Node3D.new()
        rock.position = Vector3(x,-2.0,-59.0-float(n%3)*8.0)
        root.add_child(rock)
        Art.ball(rock, 13.0, colors[n%4], Vector3(0,2,0),Vector3(0.95,1.1+float(n%3)*0.22,0.57))
        Art.ball(rock,6.5,"#82a99a",Vector3(4,10,0),Vector3(1.7,1.1,0.7))

static func _waterfall(root: Node3D, origin: Vector3) -> void:
    var water := Node3D.new()
    water.position = origin
    root.add_child(water)
    Art.box(water,Vector3(19,0.11,32),"#61b7c6",Vector3(0,-0.05,0))
    Art.box(water,Vector3(11,11,0.28),"#7bd6e4",Vector3(0,6,-14))
    for i in range(11):
        var x := float(i-5)*1.05
        Art.box(water,Vector3(0.17,9.5,0.18),"#d2f2ed",Vector3(x,6.0,-13.7))
        Art.ball(water,0.7,"#e4ffff",Vector3(x,0.42,-13.4),Vector3(1,0.3,0.5))
    for s in [-1.0,1.0]:
        for i in range(4):
            Art.ball(water,2.3,"#798f89",Vector3(s*8.5,float(i)*1.6,-12),Vector3(1.5,0.85,1.05))

static func _bridge(root: Node3D, origin: Vector3) -> void:
    var bridge := Node3D.new()
    bridge.position = origin
    root.add_child(bridge)
    for s in [-1.0,1.0]:
        for n in range(6):
            var z := float(n-2.5)*1.6
            var rise := 1.0 + (1.0-absf(z/5.0))*1.2
            Art.box(bridge,Vector3(0.3,rise,0.3),"#a9474d",Vector3(s*4.0,rise/2.0,z))
        Art.box(bridge,Vector3(0.23,0.25,10.7),"#d56a58",Vector3(s*4.0,2.0,0))
    Art.box(bridge,Vector3(8.3,0.4,11.0),"#af714f",Vector3(0,0.85,0))
    for n in range(6):
        Art.box(bridge,Vector3(8.4,0.07,0.12),"#e3b785",Vector3(0,1.1,float(n-3)*1.7))

static func _flowering_tree(root: Node3D, origin: Vector3, seed: int) -> void:
    var tr := Node3D.new()
    tr.position = origin
    root.add_child(tr)
    Art.cylinder(tr,0.35,5.1,"#76556b",Vector3(0,2.55,0),0.21)
    var petal := "#f8afd0" if seed%2==0 else "#f1c4dd"
    for i in range(8):
        var a := TAU*float(i)/8.0
        var r := 1.5+float((seed+i)%3)*0.38
        Art.ball(tr,1.5,petal,Vector3(cos(a)*r,5.2+sin(a*2.0)*0.55,sin(a)*r),Vector3(1.05,0.85,0.96))
    Art.ball(tr,1.65,"#f9cade",Vector3(0,6.15,0))

static func _shrub(root: Node3D, where: Vector3, seed: int) -> void:
    var s := Node3D.new()
    s.position = where
    root.add_child(s)
    var c: String = ["#508e6a","#66ad71","#8bb96f"][seed%3]
    for k in range(4):
        var angle := TAU*float(k)/4.0
        Art.ball(s,0.8,c,Vector3(cos(angle)*0.7,0.6,sin(angle)*0.7),Vector3(1,0.7,1))

static func _lanterns(root: Node3D) -> void:
    for side in [-1.0,1.0]:
        for i in range(4):
            var z := -14.0 + float(i)*9.2
            var post := Node3D.new()
            post.position = Vector3(side*19.5,0,z)
            root.add_child(post)
            Art.cylinder(post,0.13,2.3,"#3c435d",Vector3(0,1.15,0))
            Art.box(post,Vector3(0.78,0.8,0.78),"#ffe9ad",Vector3(0,2.56,0))
            Art.box(post,Vector3(1.08,0.17,1.08),"#455174",Vector3(0,3.02,0))
            Art.ball(post,0.17,"#f9dc9f",Vector3(0,3.17,0))

static func _training_props(root: Node3D) -> void:
    for n in range(7):
        var x := -15.0 if n%2==0 else 15.0
        var z := -12.0+float(n)*4.0
        var p := Node3D.new()
        p.position = Vector3(x,0,z)
        root.add_child(p)
        Art.box(p,Vector3(0.9,0.85,0.95),"#9b6e4b",Vector3(0,0.43,0))
        Art.box(p,Vector3(0.94,0.16,1.0),"#c6915d",Vector3(0,0.95,0))
        Art.box(p,Vector3(0.12,0.9,0.97),"#d5ad79",Vector3(0.29,0.43,0))
        Art.box(p,Vector3(0.12,0.9,0.97),"#d5ad79",Vector3(-0.29,0.43,0))
