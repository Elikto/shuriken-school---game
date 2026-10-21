extends SceneTree
## Only used by Linux CI with Xvfb + Mesa to capture the real Godot renderer.

func _initialize() -> void:
    call_deferred("_capture")

func _capture() -> void:
    var scene: PackedScene = load("res://main.tscn")
    if scene == null:
        quit(1)
        return
    var world = scene.instantiate()
    root.add_child(world)
    await process_frame
    world._start()
    world.player.position = Vector3(0,0,6)
    for scroll in world.scrolls.duplicate():
        world.player.global_position = scroll.global_position
        world._collect_scrolls()
    world.player.global_position = Vector3(0,0,6)
    world._spawn_enemy(false)
    world._spawn_enemy(false)
    for i in range(45):
        await process_frame
    var img: Image = root.get_texture().get_image()
    if img == null or img.is_empty():
        push_error("Godot screenshot empty")
        quit(1)
        return
    var code: Error = img.save_png("res://preview.png")
    if code != OK:
        push_error("Godot PNG capture error %d" % code)
        quit(1)
        return
    print("SCREENSHOT CAPTURED %s×%s" % [img.get_width(),img.get_height()])
    quit(0)