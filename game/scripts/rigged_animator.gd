extends RefCounted
## Lightweight animation of imported Blender Skeleton3D bone poses.
## These are original procedural gameplay gestures, not canonical show animations.
## The player calls this for GLB models; older polygon stand-ins keep their own animator.
const IDLE: StringName = &"idle"
const RUN: StringName = &"run"
const SKATE: StringName = &"skate"
const JUMP: StringName = &"jump"
const FALL: StringName = &"fall"
const WALLRUN: StringName = &"wallrun"
const ATTACK: StringName = &"attack"
const DODGE: StringName = &"dodge"

static func pose(skeleton: Skeleton3D, hero: int, action: StringName, time: float, delta: float, motion: float, combo: int = 0) -> void:
    if not is_instance_valid(skeleton):
        return
    var amplitude: float = clampf(motion, 0.0, 1.0)
    var rhythm: float = sin(time * 12.0) * amplitude
    var chest: Vector3 = Vector3(0.025 + sin(time * 1.9) * 0.025, 0.0, 0.0)
    var face: Vector3 = Vector3(-0.02 + sin(time * 1.5) * 0.015, 0.0, 0.0)
    var arm_l: Vector3 = Vector3(sin(time * 1.9) * 0.035, 0.0, 0.07)
    var arm_r: Vector3 = Vector3(-arm_l.x, 0.0, -0.07)
    var leg_l: Vector3 = Vector3.ZERO
    var leg_r: Vector3 = Vector3.ZERO
    var hips: Vector3 = Vector3.ZERO
    match action:
        RUN:
            chest.x = 0.16
            face.x = -0.07
            arm_l.x = -rhythm * 0.70
            arm_r.x = rhythm * 0.70
            leg_l.x = rhythm * 0.58
            leg_r.x = -rhythm * 0.58
            hips.z = rhythm * 0.055
        SKATE:
            chest.x = 0.27
            hips.z = sin(time * 5.0) * 0.09
            arm_l = Vector3(-0.75, 0.0, -0.28)
            arm_r = Vector3(0.45, 0.0, 0.32)
            leg_l = Vector3(0.22, 0.0, 0.06)
            leg_r = Vector3(-0.28, 0.0, -0.07)
        JUMP:
            chest.x = -0.12
            face.x = 0.12
            arm_l.x = -1.20
            arm_r.x = -1.28
            leg_l.x = 0.74
            leg_r.x = 0.18
        FALL:
            chest.x = 0.16
            arm_l.x = -0.66
            arm_r.x = -0.66
            leg_l.x = 0.22
            leg_r.x = -0.18
        WALLRUN:
            chest = Vector3(0.18, 0.0, 0.22)
            arm_l.x = -0.94
            arm_r.x = 0.24
            leg_l.x = sin(time * 15.0) * 0.48
            leg_r.x = -leg_l.x
        ATTACK:
            chest = Vector3(0.30, 0.0, -0.18 if combo % 2 == 0 else 0.18)
            arm_l.x = -0.40
            arm_r = Vector3(-1.48, 0.0, -0.5 if combo % 2 == 0 else 0.35)
            leg_l.x = 0.27
            leg_r.x = -0.34
        DODGE:
            chest = Vector3(0.63, 0.0, -0.32)
            face.x = -0.16
            arm_l.x = -0.93
            arm_r.x = -0.82
            leg_l.x = 0.77
            leg_r.x = 0.31
        _:
            pass

    # All children are skinned to these named bones. Rotation is applied relative
    # to their imported rest transforms rather than to mesh instance transforms.
    var targets: Dictionary = {
        "Pelvis": hips,
        "Spine": chest,
        "Head": face,
        "ArmL": arm_l,
        "ArmR": arm_r,
        "LegL": leg_l,
        "LegR": leg_r
    }
    var blend: float = clampf(delta * 13.0, 0.0, 1.0)
    for bone_name in targets:
        var index: int = skeleton.find_bone(String(bone_name))
        if index < 0:
            continue
        var angles: Vector3 = targets[bone_name]
        # Independent pitch and bank keeps silhouette readable from high camera.
        var target: Quaternion = Quaternion(Vector3.RIGHT, angles.x) * Quaternion(Vector3.FORWARD, angles.z)
        var previous: Quaternion = skeleton.get_bone_pose_rotation(index)
        skeleton.set_bone_pose_rotation(index, previous.slerp(target, blend))
