extends SceneTree
## Non-rendering functional smoke test, Godot 4.6.3.

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, description: String) -> void:
    if ok:
        print("PASS: " + description)
    else:
        failures += 1
        push_error("FAIL: " + description)

func _run() -> void:
    var scene: PackedScene = load("res://main.tscn")
    check(scene != null, "scene 3D chargee")
    if scene == null:
        quit(1)
        return
    var world = scene.instantiate()
    root.add_child(world)
    await process_frame
    check(is_instance_valid(world.player), "joueur instancie")
    check(world.hud != null and world.overlay != null, "interface 3D instanciee")
    check(world.wave == 0, "menu initial")
    world._start()
    await process_frame
    check(world.wave == 1, "vague 1 demarree")
    check(world.waiting_spawns == 5, "taille vague 1")
    world.player.select_hero(0)
    world.player.perform_skill()
    check(world.player.smoke_timer > 0.0, "Eizan utilise le nuage de fumee")
    world.player.select_hero(2)
    check(world.player.hero_index == 2, "selection Jimmy B")
    world.waiting_spawns = 0
    for enemy in world.foes.duplicate():
        if is_instance_valid(enemy):
            enemy.hit(9999)
    world._update_stage(0.02)
    await process_frame
    check(world.waiting_for_chest, "coffre apres vague")
    check(world.chests.size() == 1, "creation du coffre")
    world.player.position = Vector3(-0.8, 0.0, 0.0)
    world._on_interact()
    await process_frame
    check(world.wave == 2, "coffre fait progresser en vague 2")
    check(world.currency >= 30, "gain de pieces")
    world._end_game("TEST", "fin")
    check(world.ended and not world.active, "fin de session")
    print("SMOKE RESULT: %s failures" % failures)
    quit(1 if failures > 0 else 0)
