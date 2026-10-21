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

static func ninja(parent: Node3D, kind: int, opponent: bool = false, giant: bool = false) -> Node3D:
    # Rounded, three-dimensional stylized mannequin. This is original temporary
    # concept geometry, not an official character model or an episode likeness.
    var model := Node3D.new()
    parent.add_child(model)
    var jacket: String = ["#c36b4f", "#6660a5", "#337d88"][kind%3]
    var dark: String = ["#39445d", "#3a365e", "#254b55"][kind%3]
    var hair: String = ["#3d3c4f", "#4d3148", "#44385a"][kind%3]
    if opponent:
        jacket = ["#9a4a70", "#725480", "#886481"][kind%3]
        dark = "#35334e"
        hair = "#373349"
    var skin := "#e4aa85"
    # Smooth silhouette: rounded chest, hips, tapering lower garments.
    ball(model,0.52,jacket,Vector3(0,1.30,0),Vector3(0.89,1.02,0.71))
    ball(model,0.34,dark,Vector3(0,0.88,0),Vector3(1.0,0.66,0.88))
    box(model,Vector3(0.72,0.12,0.49),"#d3b47a",Vector3(0,0.96,0))
    ball(model,0.39,skin,Vector3(0,1.99,0),Vector3(1.02,1.10,0.89))
    # Hairstyle caps, eyebrows and distinguishable eye highlights.
    ball(model,0.40,hair,Vector3(0,2.21,0.06),Vector3(1.09,0.45,0.99))
    for side in [-1.0,1.0]:
        ball(model,0.047,"#1e253c",Vector3(side*0.155,2.03,-0.346))
        ball(model,0.018,"#fff5e0",Vector3(side*0.145,2.045,-0.39))
        box(model,Vector3(0.15,0.025,0.035),hair,Vector3(side*0.155,2.14,-0.345),Vector3(0,0,side*-0.14))
        ball(model,0.18,jacket,Vector3(side*0.49,1.52,0))
        _line(model,Vector3(side*0.52,1.43,0),Vector3(side*0.62,0.94,0.02),0.18,jacket)
        ball(model,0.12,skin,Vector3(side*0.62,0.86,0.0))
        _line(model,Vector3(side*0.23,0.77,0),Vector3(side*0.26,0.26,0),0.27,dark)
        ball(model,0.18,"#323a50",Vector3(side*0.26,0.19,-0.08),Vector3(1.15,0.56,1.32))
    # Cloth neck scarf and tiny folded tail sway as the mannequin moves.
    ball(model,0.17,"#eacb95",Vector3(0,1.68,0),Vector3(1.65,0.55,1.0))
    box(model,Vector3(0.17,0.53,0.12),"#eacb95",Vector3(0.23,1.35,0.24),Vector3(0,0,-0.2))
    if kind == 0 and not opponent:
        box(model,Vector3(0.47,0.065,0.10),"#6d9e6e",Vector3(-0.40,0.96,-0.34),Vector3(0,-0.32,0))
    if kind == 1 and not opponent:
        ball(model,0.20,hair,Vector3(0.0,2.53,0.09),Vector3(0.75,1.1,0.75))
    if kind == 2 and not opponent:
        box(model,Vector3(0.9,0.10,0.16),"#e1c0b5",Vector3(0,0.12,-0.20))
    if giant:
        model.scale = Vector3(1.65,1.72,1.65)
        cylinder(model,0.43,0.20,"#dfbd73",Vector3(0,2.52,0))
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
