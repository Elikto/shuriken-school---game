"""Generate three ORIGINAL rigged, cartoon-student GLB models with Blender.
Run on the GitHub runner, not on the user's Windows machine:
 blender -b --python tools/blender/generate_heroes.py -- --output-dir dist/models
These are provisional designs. No official textures, meshes, sounds or paid APIs.
"""
import argparse
import math
import sys
from pathlib import Path

import bpy

PALETTES = {
    "eizan": ("#ebba99", "#1b2035", "#1a2033", "#397acc"),
    "okuni": ("#f0c39e", "#a7643e", "#1a2233", "#3a83c9"),
    "jimmy": ("#b57952", "#1b1d31", "#1b2334", "#367bc3"),
}


def linear_hex(value):
    numbers = [int(value[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    return tuple(x / 12.92 if x < 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in numbers) + (1.0,)


def material(name, color):
    m = bpy.data.materials.new(name)
    m.diffuse_color = linear_hex(color)
    m.use_nodes = True
    principled = m.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = m.diffuse_color
    principled.inputs["Roughness"].default_value = 0.9
    return m


def skin(obj, rig, bone_name, mat):
    obj.data.materials.append(mat)
    weights = obj.vertex_groups.new(name=bone_name)
    weights.add(list(range(len(obj.data.vertices))), 1, "REPLACE")
    armature_modifier = obj.modifiers.new("ArmatureSkin", "ARMATURE")
    armature_modifier.object = rig
    return obj


def sphere(name, xyz, radii, mat, rig, bone_name, segments=16, rings=10):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=xyz)
    obj = bpy.context.object
    obj.name = name
    obj.scale = radii
    for face in obj.data.polygons:
        face.use_smooth = True
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return skin(obj, rig, bone_name, mat)


def box(name, xyz, size, mat, rig, bone_name, bevel=0.05):
    bpy.ops.mesh.primitive_cube_add(size=1, location=xyz)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    mod = obj.modifiers.new("RoundEdges", "BEVEL")
    mod.width, mod.segments = bevel, 3
    bpy.ops.object.modifier_apply(modifier=mod.name)
    return skin(obj, rig, bone_name, mat)


def new_rig():
    bpy.ops.object.armature_add(enter_editmode=True)
    rig = bpy.context.object
    rig.name = "HeroSkeleton"
    bones = rig.data.edit_bones
    for old_bone in list(bones):
        bones.remove(old_bone)

    def create(name, head, tail, parent=None):
        bone = bones.new(name)
        bone.head = head
        bone.tail = tail
        if parent:
            bone.parent = bones[parent]

    create("Root", (0, 0, 0.06), (0, 0, 0.72))
    create("Pelvis", (0, 0, 0.73), (0, 0, 1.06), "Root")
    create("Spine", (0, 0, 1.06), (0, 0, 1.62), "Pelvis")
    create("Head", (0, 0, 1.77), (0, 0, 2.32), "Spine")
    create("ArmL", (-0.48, 0, 1.52), (-0.57, 0, 0.97), "Spine")
    create("ArmR", (0.48, 0, 1.52), (0.57, 0, 0.97), "Spine")
    create("LegL", (-0.22, 0, 0.90), (-0.22, 0, 0.19), "Pelvis")
    create("LegR", (0.22, 0, 0.90), (0.22, 0, 0.19), "Pelvis")
    bpy.ops.object.mode_set(mode="OBJECT")
    return rig


def animate(rig, hero):
    rig.animation_data_create()
    action = bpy.data.actions.new(name="Idle_" + hero)
    rig.animation_data.action = action
    for frame, amount in ((1, 0.0), (13, 1.0), (25, 0.0)):
        for name, tilt in (("Spine", 0.04), ("Head", -0.025), ("ArmL", -0.06), ("ArmR", 0.06)):
            bone = rig.pose.bones[name]
            bone.rotation_mode = "XYZ"
            bone.rotation_euler.x = tilt * amount
            bone.keyframe_insert(data_path="rotation_euler", frame=frame)
    action.use_fake_user = True
    bpy.context.scene.frame_start = 1
    bpy.context.scene.frame_end = 25
    bpy.context.scene.frame_set(1)


def generate(hero, colors, output):
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    # Prevent actions from the previous hero leaking into the next GLB export.
    for old_action in list(bpy.data.actions):
        bpy.data.actions.remove(old_action)
    rig = new_rig()
    skin_mat, hair, suit, trim = [
        material(hero + "_" + label, value)
        for label, value in zip(("Skin", "Hair", "Suit", "Trim"), colors)
    ]
    eyes = material(hero + "_Eyes", "#182135")
    white = material(hero + "_Glint", "#faf9f0")
    leather = material(hero + "_Leather", "#20263b")
    gold = material(hero + "_Gold", "#d4ae71")
    sphere("Torso", (0, 0, 1.36), (.46, .30, .42), suit, rig, "Spine")
    sphere("Hips", (0, 0, .94), (.34, .26, .22), suit, rig, "Pelvis")
    box("WideBelt", (0, -.02, 1.01), (.74, .55, .14), trim, rig, "Pelvis")
    box("Collar", (0, -.16, 1.65), (.63, .21, .16), trim, rig, "Spine")
    sphere("Face", (0, -.04, 2.04), (.44, .35, .43), skin_mat, rig, "Head")
    sphere("HairCap", (0, .02, 2.32), (.48, .36, .22), hair, rig, "Head")
    for side, suffix in ((-1, "L"), (1, "R")):
        sphere("Eye" + suffix, (side*.16,-.374,2.07), (.065,.024,.083), eyes, rig, "Head", 10, 7)
        sphere("Glint" + suffix, (side*.18,-.4,2.10), (.017,.012,.021), white, rig, "Head", 8, 6)
        sphere("Arm" + suffix, (side*.53,0,1.30), (.16,.17,.32), suit, rig, "Arm"+suffix)
        sphere("Hand" + suffix, (side*.59,-.01,1.02), (.14,.13,.15), skin_mat, rig, "Arm"+suffix)
        box("Cuff" + suffix, (side*.58,0,1.14), (.29,.28,.12), trim, rig, "Arm"+suffix)
        sphere("Leg" + suffix, (side*.22,0,.52), (.21,.22,.38), suit, rig, "Leg"+suffix)
        box("Ankle" + suffix, (side*.22,0,.22), (.35,.33,.12), trim, rig, "Leg"+suffix)
        sphere("Shoe" + suffix, (side*.22,-.12,.105), (.22,.34,.11), leather, rig, "Leg"+suffix)

    if hero == "eizan":
        box("StraightHairFringe", (0,-.29,2.30), (.84,.13,.19), hair, rig, "Head", .045)
        practice = material("GreenPracticeRuler", "#51c995")
        box("TrainingRuler", (.69,-.12,.87), (.11,.15,.88), practice, rig, "ArmR")
    elif hero == "okuni":
        for side, suffix in ((-1, "L"), (1, "R")):
            sphere("Pigtail"+suffix, (side*.59,0,2.22), (.27,.28,.27), hair, rig, "Head")
            sphere("Tie"+suffix, (side*.44,.0,2.22), (.08,.12,.10), trim, rig, "Head")
        for index in range(15):
            theta = index * math.pi / 14
            sphere("Rope_%02d" % index, (.66*math.cos(theta),-.17,.60-.50*math.sin(theta)),
                   (.042,.042,.042), gold, rig, "ArmR", 8, 6)
    else:
        for index in range(5):
            sphere("HairSpike"+str(index), ((index-2)*.17,.04,2.46+(index%2)*.08),
                   (.12,.14,.27), hair, rig, "Head", 12, 8)
        deck = material("OriginalBlueSkateDeck", "#2873b7")
        box("SkateDeck", (0,0,.06), (1.25,.42,.08), deck, rig, "Root")
        for side in (-1,1):
            for z in (-.18,.18):
                sphere("Wheel_"+str(side)+"_"+str(z), (side*.45,z,-.01),
                       (.095,.09,.11),gold,rig,"Root",10,7)

    animate(rig, hero)
    bpy.ops.object.select_all(action="DESELECT")
    rig.select_set(True)
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":
            obj.select_set(True)
    bpy.context.view_layer.objects.active = rig
    output.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(output), export_format="GLB",
                              use_selection=True, export_animations=True,
                              export_skins=True, export_yup=True)
    if output.stat().st_size < 8000:
        raise RuntimeError("GLB missing or too small: " + str(output))
    print("MODEL_OK", hero, output, output.stat().st_size)


def main():
    argv = sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=Path("dist/models"))
    options = parser.parse_args(argv)
    for hero, palette in PALETTES.items():
        generate(hero, palette, options.output_dir / (hero + ".glb"))
    print("PIPELINE_OK: 3 rigged original cartoon GLBs")


if __name__ == "__main__":
    main()
