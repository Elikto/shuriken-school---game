extends RefCounted
## Original stylized scenery. Not traced/copied from television episode backgrounds.
const Art = preload("res://scripts/art.gd")

static func create(parent: Node3D, chapter: int) -> Node3D:
    var root := Node3D.new()
    root.name = "ChapterArt"
    parent.add_child(root)
    match chapter:
        0:
            _dojo(root)
        1:
            _garden(root)
        2:
            _gate(root)
    return root

static func _banner(parent: Node3D, where: Vector3, color: String, height: float = 4.8) -> void:
    var root := Node3D.new()
    root.position = where
    parent.add_child(root)
    Art.cylinder(root, 0.09, height, "#51465d", Vector3(0, height/2.0, 0))
    Art.box(root, Vector3(1.55, 2.2, 0.08), color, Vector3(0.65, height-1.45, 0))
    Art.box(root, Vector3(1.75, 0.14, 0.18), "#ffe2aa", Vector3(0.65, height-0.34, 0))
    Art.ball(root, 0.17, "#ffe2aa", Vector3(0, height+0.1, 0))

static func _dojo(parent: Node3D) -> void:
    for i in range(6):
        var a := float(i)*TAU/6.0
        _banner(parent, Vector3(cos(a)*16.0, 0, sin(a)*16.0), "#e68f75")
        var target := Node3D.new()
        parent.add_child(target)
        target.position = Vector3(cos(a)*12, 0, sin(a)*12)
        Art.cylinder(target, 0.10, 2.9, "#7d6767", Vector3(0,1.45,0))
        Art.cylinder(target, 0.75, 0.15, "#f6e4bf", Vector3(0,2.9,0))
        Art.cylinder(target, 0.37, 0.17, "#d56c7c", Vector3(0,3.0,0))

static func _garden(parent: Node3D) -> void:
    for i in range(30):
        var angle := float(i)*2.399963
        var radius := 12.0+fmod(float(i)*7.31, 8.5)
        var tuft := Node3D.new()
        tuft.position = Vector3(cos(angle)*radius,0,sin(angle)*radius)
        parent.add_child(tuft)
        for stalk in range(3):
            var height := 3.6+float((i+stalk)%4)*0.70
            Art.cylinder(tuft,0.12,height,"#6b9e78",Vector3(float(stalk)*0.26,height/2.0,0))
            for joint in range(1,4):
                Art.cylinder(tuft,0.15,0.10,"#d4dbaa",Vector3(float(stalk)*0.26,height*float(joint)/4.0,0))
        Art.ball(tuft,0.65,"#8bc18c",Vector3(0,0.45,0),Vector3(1.1,0.5,0.7))
    for i in range(15):
        var z := float(i)*2.65-18.5
        Art.box(parent,Vector3(4.0,0.04,1.7),"#b4beaf",Vector3(-15,0.04,z),Vector3(0,0.08*float(i%3),0))
    for i in range(8):
        var theta := TAU * float(i)/8.0
        var lamp := Node3D.new()
        lamp.position = Vector3(sin(theta)*8.0,0,cos(theta)*8.0)
        parent.add_child(lamp)
        Art.cylinder(lamp,0.16,1.8,"#607985",Vector3(0,0.9,0))
        Art.ball(lamp,0.38,"#f7d399",Vector3(0,2.05,0))

static func _gate(parent: Node3D) -> void:
    for i in range(10):
        var x := float(i-5)*4.0+2.0
        _banner(parent,Vector3(x,0,-17),"#9a527a",5.2)
        _banner(parent,Vector3(x,0,17),"#784e94",4.2)
    for side in [-1.0,1.0]:
        for i in range(7):
            var z := float(i)*5.8-17.4
            var tower := Node3D.new()
            tower.position = Vector3(side*17,0,z)
            parent.add_child(tower)
            Art.cylinder(tower,0.63,3.0,"#8a8095",Vector3(0,1.5,0))
            Art.box(tower,Vector3(1.9,0.36,1.9),"#52435e",Vector3(0,3.15,0))
            Art.ball(tower,0.25,"#f4bf79",Vector3(0,3.55,0))
