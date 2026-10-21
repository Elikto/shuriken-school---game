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
            # Actual runtime gameplay poses must rotate Blender bones, not
            # merely rely on an idle animation embedded in the GLB file.
            var rig_animator = load("res://scripts/rigged_animator.gd")
            var right_arm_index: int = skeleton.find_bone("ArmR")
            var left_leg_index: int = skeleton.find_bone("LegL")
            if right_arm_index >= 0 and left_leg_index >= 0:
                rig_animator.pose(skeleton, 0, &"attack", 0.5, 0.25, 0.0, 1)
                var strike_angle: float = skeleton.get_bone_pose_rotation(right_arm_index).angle_to(Quaternion.IDENTITY)
                check(strike_angle > 0.4, hero + " imported skeleton responds to attack")
                rig_animator.pose(skeleton, 0, &"run", 0.2, 0.25, 1.0)
                var run_angle: float = skeleton.get_bone_pose_rotation(left_leg_index).angle_to(Quaternion.IDENTITY)
                check(run_angle > 0.1, hero + " imported skeleton responds to running")
                rig_animator.pose(skeleton, 0, &"jump", 0.2, 0.25, 0.0)
                var jump_angle: float = skeleton.get_bone_pose_rotation(left_leg_index).angle_to(Quaternion.IDENTITY)
                check(jump_angle > 0.5, hero + " imported skeleton responds to jumping")
        check(not players.is_empty(), hero + " GLB includes an AnimationPlayer")
        if not players.is_empty():
            var anim: AnimationPlayer = players[0]
            check(not anim.get_animation_list().is_empty(), hero + " animation imported")
        rig.queue_free()
        await process_frame
    print("GLB_GODOT_TEST_RESULT: %d error(s)" % errors)
    quit(1 if errors > 0 else 0)
