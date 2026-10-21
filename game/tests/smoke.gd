extends SceneTree
## Comprehensive headless gameplay regression tests (no graphics/GPU benchmark).
const Progress = preload("res://scripts/progress.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func check(ok: bool, label: String) -> void:
    if ok:
        print("PASS: "+label)
    else:
        failures += 1
        push_error("FAIL: "+label)

func _run() -> void:
    var profile_path := "user://smoke_campaign_profile.json"
    var base: Dictionary = Progress.defaults()
    check(base["unlocked"] == 1, "first mission unlocked by default")
    var done: Dictionary = Progress.finish_chapter(base,0,2,34)
    check(done["unlocked"] == 2 and done["total_coins"] == 34, "mission unlocks next zone")
    check(Progress.write_profile(done,profile_path), "save campaign profile")
    var restored: Dictionary = Progress.read_profile(profile_path)
    check(restored["best_stars"][0] == 2 and restored["total_coins"] == 34, "restore profile")
    var second: Dictionary = Progress.finish_chapter(restored,1,3,99)
    check(second["unlocked"] == 3, "third mission unlocks")
    check(Progress.finish_chapter(second,1,1,0)["best_stars"][1] == 3, "stars do not regress")

    var main: PackedScene = load("res://main.tscn")
    check(main != null,"main 3D scene loads")
    if main == null:
        quit(1)
        return
    var world = main.instantiate()
    root.add_child(world)
    await process_frame
    check(is_instance_valid(world.player),"ninja player exists")
    check(world.hud != null and world.overlay != null,"HUD + main menu exist")
    check(world.wave == 0,"start at menu")
    world._start()
    await process_frame
    check(world.gathering and world.scrolls.size() == 3,"collectible quest starts")
    for scroll in world.scrolls.duplicate():
        world.player.global_position = scroll.global_position
        world._collect_scrolls()
    check(world.scrolls_found == 3 and world.wave == 1,"collect 3 scrolls to unlock waves")
    check(world.waiting_spawns == 5,"first wave requires 5 foes")

    world.player.select_hero(0)
    world.player.perform_skill()
    check(world.player.smoke_timer > 0.0,"Eizan smoke special")
    world.player.select_hero(2)
    check(world.player.hero_index == 2 and world.player.smoke_timer == 0.0,"hero switch cancels concealment")
    world.player.perform_attack()
    check(world.player.combo_count == 1,"combo first hit")
    world.player.attack_timer = 0.0
    world.player.perform_attack()
    check(world.player.combo_count == 2,"combo second hit")
    world.player.attack_timer = 0.0
    world.player.perform_attack()
    check(world.player.combo_count == 3,"combo finisher")

    world.waiting_spawns = 0
    for enemy in world.foes.duplicate():
        if is_instance_valid(enemy):
            enemy.hit(9999)
    world._update_stage(0.02)
    await process_frame
    check(world.waiting_for_chest and world.chests.size() == 1,"chest after clearing a wave")
    world.player.position = Vector3(-0.8,0,0)
    world._on_interact()
    await process_frame
    check(world.wave == 2 and world.session_upgrade == 1,"chest gives weapon upgrade and wave two")

    world._next_wave()
    world._next_wave()
    await process_frame
    check(world.boss_active and world.foes.size() >= 1,"boss starts after three waves")
    var boss = world.foes.back()
    check(boss.boss and boss.max_hp >= 360,"boss has durable HP")
    boss.hp = int(float(boss.max_hp)*0.25)
    boss._physics_process(0.04)
    check(boss.phase == 3,"boss has third combat phase")
    boss.warning_started.emit(Vector3.ZERO,4.5)
    check(world.warnings.size() == 1,"boss attacks have warnings")
    world.player.dash_invincible = 0
    var hp_before: int = world.player.health
    world.player.position = Vector3.ZERO
    world._enemy_area(Vector3.ZERO,4.5,5)
    check(world.player.health == hp_before-5,"area attack hits player in range")
    world._victory()
    check(world.ended and world.victory_ready,"victory after first chapter")
    check(int(world.profile["unlocked"]) >= 2,"first victory unlocks next chapter")
    world._select_chapter(1)
    await process_frame
    check(world.selected_chapter == 1 and world.gathering,"next story chapter starts")
    check(world.scrolls.size() == 3,"next chapter has new objectives")
    world._end_game("TEST","fin")
    check(world.ended,"game over ends gameplay")
    print("GAMEPLAY TEST RESULT: %d error(s)" % failures)
    quit(1 if failures > 0 else 0)
