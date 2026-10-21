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
    # Blue and black costume palette inspired by the television's costume direction.
    # Purely original procedural silhouettes: not a licensed model or animation.
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
    ball(model,0.44,suit,Vector3(0,1.28,0),Vector3(0.94,1.08,0.75))
    ball(model,0.32,suit,Vector3(0,0.86,0),Vector3(1.05,0.63,0.95))
    box(model,Vector3(0.88,0.16,0.52),blue,Vector3(0,0.97,0))
    box(model,Vector3(0.2,0.46,0.10),blue,Vector3(0.22,0.77,0.29),Vector3(0,0,-0.21))
    # Distinctive oversized cartoon heads, cheeks and brow.
    ball(model,0.41,skin,Vector3(0,1.98,0),Vector3(1.10,1.08,0.90))
    ball(model,0.40,hair,Vector3(0,2.23,0.065),Vector3(1.19,0.43,1.04))
    for s in [-1.0,1.0]:
        ball(model,0.063,"#151c2c",Vector3(s*0.16,2.025,-0.36),Vector3(0.9,1.2,0.45))
        ball(model,0.020,"#ffffff",Vector3(s*0.155,2.05,-0.389))
        box(model,Vector3(0.18,0.030,0.048),hair,Vector3(s*0.16,2.15,-0.356),Vector3(0,0,-s*0.1))
    if not opponent and kind == 0:
        # Eizan: straight dark fringe and a long, glowing-green practice ruler.
        box(model,Vector3(0.80,0.18,0.12),hair,Vector3(0,2.26,-0.31))
        box(model,Vector3(0.13,0.65,0.13),"#56c880",Vector3(0.65,0.96,-0.20),Vector3(0,0,0.50))
        for n in range(3):
            box(model,Vector3(0.09,0.015,0.025),"#d0ffd5",Vector3(0.70+float(n)*0.12,1.12+float(n)*0.12,-0.28),Vector3(0,0,0.5))
    elif not opponent and kind == 1:
        # Okuni: two rounded orange pigtails, blue cuffs and rope.
        for s in [-1.0,1.0]:
            ball(model,0.265,hair,Vector3(s*0.55,2.10,0.06),Vector3(0.93,0.9,0.96))
            box(model,Vector3(0.12,0.09,0.14),blue,Vector3(s*0.43,2.12,0.06))
        var rope := Node3D.new()
        rope.name = "JumpRope"
        model.add_child(rope)
        for n in range(11):
            var a := PI * float(n)/10.0
            ball(rope,0.035,"#eee1c2",Vector3(cos(a)*0.73,0.63-sin(a)*0.52,-0.10))
    elif not opponent and kind == 2:
        # Jimmy: spiked hair and his skateboard.
        for i in range(5):
            var tip := ball(model,0.22,hair,Vector3(float(i-2)*0.18,2.35+float(i%2)*0.10,0.11),Vector3(0.7,1.5,0.72))
            tip.rotation.z = float(i-2)*0.30
        box(model,Vector3(1.30,0.08,0.46),"#256cac",Vector3(0,0.08,0.09))
        for s in [-1.0,1.0]:
            ball(model,0.11,"#e8ae42",Vector3(s*0.46,0.05,0.36))
    elif opponent:
        # Anonymous original adversary, not a canon character.
        var hat := cylinder(model,0.56,0.10,"#383045",Vector3(0,2.38,0))
        hat.scale.z = 1.22
    _moveable_limb(model,"ArmL",Vector3(-0.48,1.53,0),suit,blue,false)
    _moveable_limb(model,"ArmR",Vector3(0.48,1.53,0),suit,blue,false)
    _moveable_limb(model,"LegL",Vector3(-0.22,0.83,0),suit,blue,true)
    _moveable_limb(model,"LegR",Vector3(0.22,0.83,0),suit,blue,true)
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
