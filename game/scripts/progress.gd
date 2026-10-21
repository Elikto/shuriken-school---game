extends RefCounted
## Small, local-only campaign save. No telemetry, cloud login, or external connection.

const SAVE_PATH := "user://shuriken_school_campaign_v1.json"
const MAX_CHAPTERS := 3

static func defaults() -> Dictionary:
    return {"version": 1, "unlocked": 1, "completed": [], "best_stars": [0, 0, 0], "total_coins": 0}

static func read_profile(path: String = SAVE_PATH) -> Dictionary:
    if not FileAccess.file_exists(path):
        return defaults()
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return defaults()
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return defaults()
    var profile: Dictionary = defaults()
    var data: Dictionary = parsed
    profile["unlocked"] = clampi(int(data.get("unlocked", 1)), 1, MAX_CHAPTERS)
    profile["total_coins"] = maxi(0, int(data.get("total_coins", 0)))
    var done = data.get("completed", [])
    if done is Array:
        for entry in done:
            var idx := int(entry)
            if idx >= 0 and idx < MAX_CHAPTERS and not profile["completed"].has(idx):
                profile["completed"].append(idx)
    var stars = data.get("best_stars", [])
    if stars is Array:
        for i in range(mini(stars.size(), MAX_CHAPTERS)):
            profile["best_stars"][i] = clampi(int(stars[i]), 0, 3)
    return profile

static func write_profile(profile: Dictionary, path: String = SAVE_PATH) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(profile, "  "))
    file.flush()
    return true

static func finish_chapter(profile: Dictionary, chapter: int, stars: int, coins: int) -> Dictionary:
    var result: Dictionary = profile.duplicate(true)
    if chapter < 0 or chapter >= MAX_CHAPTERS:
        return result
    if not result["completed"].has(chapter):
        result["completed"].append(chapter)
    result["unlocked"] = maxi(int(result["unlocked"]), mini(chapter + 2, MAX_CHAPTERS))
    result["best_stars"][chapter] = maxi(int(result["best_stars"][chapter]), clampi(stars, 1, 3))
    result["total_coins"] = maxi(0, int(result["total_coins"]) + maxi(coins, 0))
    return result
