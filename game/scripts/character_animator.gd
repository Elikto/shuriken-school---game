extends RefCounted
## Procedural expressive poses for placeholder cartoon rigs.
## Game animation only: these poses are not claims about canonical gestures.
## This module transforms existing named joints; it creates no geometry.
const STATE_IDLE: StringName = &"idle"
const STATE_RUN: StringName = &"run"
const STATE_SKATE: StringName = &"skate"
const STATE_JUMP: StringName = &"jump"
const STATE_FALL: StringName = &"fall"
const STATE_WALLRUN: StringName = &"wallrun"
const STATE_ATTACK: StringName = &"attack"
const STATE_DODGE: StringName = &"dodge"

static func pose(model: Node3D, hero: int, state: StringName, t: float, delta: float, motion: float, combo: int = 0) -> void:
    if not is_instance_valid(model):
        return
    var torso := model.get_node_or_null("Torso") as Node3D
    var head := model.get_node_or_null("Head") as Node3D
    var left_arm := model.get_node_or_null("ArmL") as Node3D
    var right_arm := model.get_node_or_null("ArmR") as Node3D
    var left_leg := model.get_node_or_null("LegL") as Node3D
    var right_leg := model.get_node_or_null("LegR") as Node3D
    if torso == null or head == null or left_arm == null or right_arm == null or left_leg == null or right_leg == null:
        return
    var weight := clampf(delta*13.0,0.0,1.0)
    var cycle := sin(t*(14.0 if state == STATE_RUN else 9.0))
    var locomotion := clampf(motion,0.0,1.0)
    var swing := cycle * locomotion * 0.58 if state == STATE_RUN else 0.0
    var torso_x := 0.04
    var torso_z := sin(t*1.8)*0.025
    var head_x := sin(t*1.4)*0.045
    var left_arm_x := -swing
    var right_arm_x := swing
    var left_leg_x := swing
    var right_leg_x := -swing
    var arm_left_z := 0.06
    var arm_right_z := -0.06
    var board_pitch := 0.0

    match state:
        STATE_RUN:
            torso_x = 0.13
            head_x = -0.08
        STATE_SKATE:
            torso_x = 0.26
            torso_z = sin(t*4.5)*0.13
            left_arm_x = -0.66
            right_arm_x = 0.39
            left_leg_x = 0.22
            right_leg_x = -0.31
            arm_left_z = -0.32
            arm_right_z = 0.37
            board_pitch = sin(t*5.0)*0.10
        STATE_JUMP:
            torso_x = -0.12
            head_x = 0.13
            left_arm_x = -1.35
            right_arm_x = -1.28
            left_leg_x = 0.75
            right_leg_x = 0.20
        STATE_FALL:
            torso_x = 0.15
            left_arm_x = -0.60
            right_arm_x = -0.60
            left_leg_x = 0.26
            right_leg_x = -0.14
        STATE_WALLRUN:
            torso_x = 0.21
            torso_z = 0.29
            left_arm_x = -1.02
            right_arm_x = 0.15
            left_leg_x = sin(t*15.0)*0.43
            right_leg_x = -left_leg_x
        STATE_ATTACK:
            torso_x = 0.31
            torso_z = -0.22 if combo%2==0 else 0.22
            left_arm_x = -0.44
            right_arm_x = -1.6
            arm_right_z = -0.68 if combo%2==0 else 0.38
            left_leg_x = 0.26
            right_leg_x = -0.31
        STATE_DODGE:
            torso_x = 0.65
            torso_z = -0.37
            head_x = -0.2
            left_arm_x = -1.05
            right_arm_x = -0.83
            left_leg_x = 0.85
            right_leg_x = 0.32
        _:
            left_arm_x = sin(t*1.8)*0.045
            right_arm_x = -left_arm_x

    torso.rotation.x = lerpf(torso.rotation.x,torso_x,weight)
    torso.rotation.z = lerpf(torso.rotation.z,torso_z,weight)
    head.rotation.x = lerpf(head.rotation.x,head_x,weight)
    head.rotation.z = lerpf(head.rotation.z,-torso_z*0.42,weight)
    left_arm.rotation.x = lerpf(left_arm.rotation.x,left_arm_x,weight)
    right_arm.rotation.x = lerpf(right_arm.rotation.x,right_arm_x,weight)
    left_arm.rotation.z = lerpf(left_arm.rotation.z,arm_left_z,weight)
    right_arm.rotation.z = lerpf(right_arm.rotation.z,arm_right_z,weight)
    left_leg.rotation.x = lerpf(left_leg.rotation.x,left_leg_x,weight)
    right_leg.rotation.x = lerpf(right_leg.rotation.x,right_leg_x,weight)
    var head_hair := head.get_node_or_null("HairL") as Node3D
    var other_hair := head.get_node_or_null("HairR") as Node3D
    if head_hair != null:
        head_hair.rotation.z = lerpf(head_hair.rotation.z,0.14*sin(t*8.0)*locomotion,weight)
    if other_hair != null:
        other_hair.rotation.z = lerpf(other_hair.rotation.z,-0.14*sin(t*8.0)*locomotion,weight)
    var eyes := head.get_node_or_null("Eyes") as Node3D
    if eyes != null:
        # Tiny infrequent idle blink, without adding mesh animation tracks.
        var blink := 0.10 if state == STATE_IDLE and fmod(t,4.2) > 4.06 else 1.0
        eyes.scale.y = lerpf(eyes.scale.y,blink,weight)
    var board := model.get_node_or_null("Board") as Node3D
    if board != null and hero == 2:
        board.rotation.x = lerpf(board.rotation.x,board_pitch,weight)
