extends SceneTree
## Blender GLB import contract tests. Run only after the model files have been generated
## in game/assets/characters by the Blender workflow.
var errors := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, what: String) -> void:
    if ok:
        print("PASS: " + what)
    else:
        errors += 1
        push_error("FAIL: " + what)

func _walk(node: Node, skeletons: Array, animation_players: Array) -> void:
    if node is Skeleton3D:
        skeletons.append(node)
    if node is AnimationPlayer:
        animation_players.append(node)
    for child in node.get_children():
        _walk(child, skeletons, animation_players)

func _run() -> void:
    for hero in ["eizan", "okuni", "jimmy"]:
        var model_path: String = "res://assets/characters/" + str(hero) + ".glb"
        check(ResourceLoader.exists(model_path), hero + " GLB registered by Godot importer")
        if not ResourceLoader.exists(model_path):
            continue
        var scene: Resource = load(model_path)
        check(scene is PackedScene, hero + " GLB imports as PackedScene")
        if not (scene is PackedScene):
            continue
        var rig: Node = (scene as PackedScene).instantiate()
        root.add_child(rig)
        var skeletons: Array = []
        var players: Array = []
        _walk(rig, skeletons, players)
        check(not skeletons.is_empty(), hero + " GLB has a Skeleton3D")
        if not skeletons.is_empty():
            var skeleton: Skeleton3D = skeletons[0]
            for bone in ["Root", "Pelvis", "Spine", "Head", "ArmL", "ArmR", "LegL", "LegR"]:
                check(skeleton.find_bone(bone) >= 0, hero + " bone " + bone + " exists")
        check(not players.is_empty(), hero + " GLB includes an AnimationPlayer")
        if not players.is_empty():
            var anim: AnimationPlayer = players[0]
            check(not anim.get_animation_list().is_empty(), hero + " animation imported")
        rig.queue_free()
        await process_frame
    print("GLB_GODOT_TEST_RESULT: %d error(s)" % errors)
    quit(1 if errors > 0 else 0)
