extends SceneTree
## CI helper only: use GitHub-hosted Android SDK and JDK to configure Godot.
func _initialize() -> void:
    var settings = EditorInterface.get_editor_settings()
    var android_home: String = OS.get_environment("ANDROID_HOME")
    var java_home: String = OS.get_environment("JAVA_HOME")
    print("ANDROID_HOME available: ", not android_home.is_empty())
    print("JAVA_HOME available: ", not java_home.is_empty())
    settings.set_setting("export/android/android_sdk_path", android_home)
    settings.set_setting("export/android/java_sdk_path", java_home)
    settings.save()
    quit(0)