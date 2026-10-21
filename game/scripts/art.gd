extends RefCounted
## Geometry generated in code: NO original television assets.
## Stylized shapes are placeholders, NOT faithful character reconstructions.

static func mat(hex_color: String, rough: float = 0.9) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(hex_color)
    m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
    m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
    m.roughness = rough
    m.cull_mode = BaseMaterial3D.CULL_BACK
    m.metallic = 0.02
    return m

static func box(parent: Node3D, size: Vector3, color: String, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var i := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    i.mesh = mesh
    i.material_override = mat(color)
    i.position = pos
    i.rotation = rot
    parent.add_child(i)
    return i

static func ball(parent: Node3D, radius: float, color: String, pos: Vector3 = Vector3.ZERO, scale_v: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var i := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 24
    mesh.rings = 12
    i.mesh = mesh
    i.material_override = mat(color)
    i.position = pos
    i.scale = scale_v
    parent.add_child(i)
    return i

static func cylinder(parent: Node3D, radius: float, height: float, color: String, pos: Vector3 = Vector3.ZERO, top_radius: float = -1.0) -> MeshInstance3D:
    var i := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.bottom_radius = radius
    mesh.top_radius = radius if top_radius < 0.0 else top_radius
    mesh.height = height
    mesh.radial_segments = 12
    i.mesh = mesh
    i.material_override = mat(color)
    i.position = pos
    parent.add_child(i)
    return i

static func _line(parent: Node3D, a: Vector3, b: Vector3, thickness: float, color: String) -> void:
    var diff := b - a
    var p := box(parent, Vector3(thickness, diff.length(), thickness), color, (a+b)*0.5)
    p.quaternion = Quaternion(Vector3.UP, diff.normalized())

static func _ink_outline(model: Node3D) -> void:
    # Inverted-hull outline, drawn only on character meshes to keep the mobile budget down.
    var shader := Shader.new()
    shader.code = "shader_type spatial; render_mode unshaded,cull_front,depth_draw_opaque; void vertex(){ VERTEX += NORMAL * 0.026; } void fragment(){ ALBEDO = vec3(0.07,0.10,0.18); }"
    var ink := ShaderMaterial.new()
    ink.shader = shader
    var pending: Array[Node] = [model]
    while not pending.is_empty():
        var n: Node = pending.pop_back()
        if n is MeshInstance3D:
            var part := n as MeshInstance3D
            if part.material_override is BaseMaterial3D:
                (part.material_override as BaseMaterial3D).next_pass = ink
        for child in n.get_children():
            pending.append(child)

static func _moveable_limb(parent: Node3D, name: String, position_v: Vector3, color: String, sock: String, is_leg: bool) -> Node3D:
    var limb := Node3D.new()
    limb.name = name
    limb.position = position_v
    parent.add_child(limb)
    if is_leg:
        ball(limb, 0.185, color, Vector3(0,-0.23,0), Vector3(0.95,1.65,0.9))
        box(limb,Vector3(0.35,0.18,0.37),sock,Vector3(0,-0.42,0))
        ball(limb,0.175,"#202338",Vector3(0,-0.57,-0.10),Vector3(1.2,0.58,1.65))
    else:
        ball(limb,0.18,color,Vector3(0,-0.17,0),Vector3(0.82,1.62,0.9))
        box(limb,Vector3(0.30,0.16,0.30),sock,Vector3(0,-0.36,0))
        ball(limb,0.12,"#f0c4a0",Vector3(0,-0.45,0))
    return limb

static func ninja(parent: Node3D, kind: int, opponent: bool = false, giant: bool = false) -> Node3D:
    # Original code-generated demonstration rig. Model proportions and costumes
    # need episode-by-episode approval before they can be called canon-faithful.
    var model := Node3D.new()
    model.name = "CartoonNinja"
    parent.add_child(model)
    var suit := "#171b29" if not opponent else "#514262"
    var blue := "#2868bf" if not opponent else "#987193"
    var skin := "#efc4a1" if not opponent else "#d7ae93"
    var hair := "#171c2a"
    if kind == 1 and not opponent:
        skin = "#f2c7a7"
        hair = "#a66338"
    if kind == 2 and not opponent:
        skin = "#aa7556"
        hair = "#111621"

    var torso := Node3D.new()
    torso.name = "Torso"
    torso.position = Vector3(0,1.21,0)
    model.add_child(torso)
    ball(torso,0.45,suit,Vector3(0,0.03,0),Vector3(0.96,1.0,0.77))
    ball(torso,0.31,suit,Vector3(0,-0.35,0),Vector3(1.06,0.65,0.95))
    box(torso,Vector3(0.87,0.15,0.54),blue,Vector3(0,-0.24,0))
    box(torso,Vector3(0.18,0.42,0.10),blue,Vector3(0.2,-0.39,0.28),Vector3(0,0,-0.21))

    var head := Node3D.new()
    head.name = "Head"
    head.position = Vector3(0,1.99,0)
    model.add_child(head)
    ball(head,0.41,skin,Vector3.ZERO,Vector3(1.10,1.09,0.91))
    ball(head,0.41,hair,Vector3(0,0.25,0.065),Vector3(1.2,0.43,1.04))
    var eyes := Node3D.new()
    eyes.name = "Eyes"
    head.add_child(eyes)
    for side in [-1.0,1.0]:
        ball(eyes,0.061,"#151c2c",Vector3(side*0.16,0.036,-0.358),Vector3(0.85,1.2,0.44))
        ball(eyes,0.02,"#ffffff",Vector3(side*0.155,0.067,-0.387))
        box(head,Vector3(0.18,0.031,0.047),hair,Vector3(side*0.16,0.16,-0.352),Vector3(0,0,-side*0.10))
    if not opponent and kind == 0:
        box(head,Vector3(0.81,0.19,0.12),hair,Vector3(0,0.27,-0.30))
    elif not opponent and kind == 1:
        for side in [-1.0,1.0]:
            var pigtail := Node3D.new()
            pigtail.name = "HairL" if side < 0 else "HairR"
            pigtail.position = Vector3(side*0.43,0.13,0.06)
            head.add_child(pigtail)
            ball(pigtail,0.27,hair,Vector3(side*0.12,-0.01,0),Vector3(0.96,0.93,0.98))
            box(pigtail,Vector3(0.13,0.09,0.14),blue,Vector3(0,0,0))
    elif not opponent and kind == 2:
        for i in range(5):
            var tip := ball(head,0.22,hair,Vector3(float(i-2)*0.18,0.36+float(i%2)*0.10,0.11),Vector3(0.7,1.45,0.72))
            tip.rotation.z = float(i-2)*0.3
    elif opponent:
        var hat := cylinder(head,0.56,0.12,"#383045",Vector3(0,0.38,0))
        hat.scale.z = 1.22

    _moveable_limb(model,"ArmL",Vector3(-0.48,1.53,0),suit,blue,false)
    var right_arm := _moveable_limb(model,"ArmR",Vector3(0.48,1.53,0),suit,blue,false)
    _moveable_limb(model,"LegL",Vector3(-0.22,0.83,0),suit,blue,true)
    _moveable_limb(model,"LegR",Vector3(0.22,0.83,0),suit,blue,true)
    if not opponent and kind == 0:
        # Ruler is parented to the hand pivot so it follows the attack.
        box(right_arm,Vector3(0.13,0.72,0.12),"#56c880",Vector3(0,-0.53,-0.14),Vector3(0,0,0.38))
        for n in range(3):
            box(right_arm,Vector3(0.08,0.012,0.025),"#c8fad8",
                Vector3(0.09+float(n)*0.05,-0.62+float(n)*0.1,-0.22),Vector3(0,0,0.38))
    elif not opponent and kind == 1:
        var rope := Node3D.new()
        rope.name = "JumpRope"
        right_arm.add_child(rope)
        for n in range(17):
            var angle := float(n)*PI/16.0
            ball(rope,0.032,"#e3d0ac",
                Vector3(cos(angle)*0.65,-0.64-sin(angle)*0.42,-0.12))
    elif not opponent and kind == 2:
        var board := Node3D.new()
        board.name = "Board"
        model.add_child(board)
        box(board,Vector3(1.28,0.08,0.45),"#256cac",Vector3(0,0.09,0.06))
        for side in [-1.0,1.0]:
            ball(board,0.11,"#e8ae42",Vector3(side*0.46,0.045,0.32))

    if giant:
        model.scale = Vector3(1.6,1.65,1.6)
        cylinder(model,0.50,0.15,"#e7b75f",Vector3(0,2.56,0))
    _ink_outline(model)
    return model

static func chest(parent: Node3D) -> Node3D:
    var model := Node3D.new()
    parent.add_child(model)
    box(model,Vector3(1.2,0.8,0.75),"#87512e",Vector3(0,0.55,0))
    box(model,Vector3(1.28,0.22,0.82),"#b67541",Vector3(0,1.05,0))
    box(model,Vector3(0.18,0.88,0.80),"#f0c76b",Vector3(-0.40,0.58,0))
    box(model,Vector3(0.18,0.88,0.80),"#f0c76b",Vector3(0.40,0.58,0))
    box(model,Vector3(0.25,0.35,0.12),"#f4df92",Vector3(0,0.7,-0.44))
    return model
