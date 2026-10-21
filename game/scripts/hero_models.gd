extends RefCounted
## Select imported Blender GLB if available, retaining a standalone procedural fallback.
## Blender assets are downloaded only during verified CI builds (no runtime network).
const Art = preload("res://scripts/art.gd")
const HERO_FILES := ["eizan.glb", "okuni.glb", "jimmy.glb"]

static func create(parent: Node3D, hero: int) -> Node3D:
    var path: String = "res://assets/characters/" + HERO_FILES[posmod(hero, HERO_FILES.size())]
    if ResourceLoader.exists(path):
        var resource = load(path)
        if resource is PackedScene:
            var imported: Node3D = (resource as PackedScene).instantiate() as Node3D
            if imported != null:
                parent.add_child(imported)
                imported.name = "BlenderHero"
                imported.set_meta("asset_source", path)
                var players: Array[Node] = imported.find_children("*", "AnimationPlayer", true, false)
                if not players.is_empty():
                    var anim: AnimationPlayer = players[0] as AnimationPlayer
                    if anim != null and not anim.get_animation_list().is_empty():
                        anim.play(anim.get_animation_list()[0])
                return imported
    return Art.ninja(parent, hero)
