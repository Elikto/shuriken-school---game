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
    mesh.radial_segments = 16
    mesh.rings = 8
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
    var model := Node3D.new()
    parent.add_child(model)
    var robe: String = ["#e8784b", "#775de0", "#32a9a3"][kind % 3]
    if opponent:
        robe = "#ae496c" if not giant else "#642c80"
    var skin := "#f6bf93"
    # Styled anonymous prototypes; no claim of accurate costume, face or proportions.
    box(model, Vector3(0.68,0.84,0.42), robe, Vector3(0,1.12,0))
    box(model, Vector3(0.74,0.12,0.47), "#f7d383", Vector3(0,0.90,0))
    ball(model,0.35,skin,Vector3(0,1.9,0))
    box(model,Vector3(0.73,0.20,0.59), "#253554" if not opponent else "#332241",Vector3(0,2.17,0))
    for side in [-1.0,1.0]:
        ball(model,0.055,"#24283c",Vector3(side*0.15,1.93,-0.316))
        _line(model,Vector3(side*0.46,1.46,0),Vector3(side*0.47,0.97,0),0.21,skin)
        _line(model,Vector3(side*0.20,0.81,0),Vector3(side*0.20,0.20,0),0.24,"#253554")
    if kind == 2 and not opponent:
        box(model,Vector3(0.7,0.11,0.12),"#ded8f2",Vector3(0,0.16,-0.21))
    if kind == 1 and not opponent:
        ball(model,0.17,"#292444",Vector3(0,2.33,0))
    if giant:
        model.scale = Vector3(1.8,1.85,1.8)
        ball(model,0.16,"#f9bd5b",Vector3(0,2.54,0))
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
