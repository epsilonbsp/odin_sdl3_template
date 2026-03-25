package main

import glm "core:math/linalg/glsl"

Camera :: struct {
    position: glm.vec3,
    forward: glm.vec3,
    right: glm.vec3,
    up: glm.vec3,
    world_up: glm.vec3,
    is_locked: bool,
    near: f32,
    far: f32,
    fov: f32,
    projection: glm.mat4,
    view: glm.mat4,
}

init_camera :: proc(
    camera: ^Camera,
    position := glm.vec3{},
    forward := glm.vec3{},
    right := glm.vec3{},
    up := glm.vec3{},
    world_up := glm.vec3{0, 1, 0},
    is_locked := true,
    near := f32(1e-3),
    far := f32(1000),
    fov := f32(90)
) {
    camera.position = position
    camera.forward = forward
    camera.right = right
    camera.up = up
    camera.world_up = world_up
    camera.is_locked = is_locked
    camera.near = near
    camera.far = far
    camera.fov = fov
    rotate_camera(camera, 0, 0, 0)
}

move_camera :: proc(camera: ^Camera, direction: glm.vec3) {
    camera.position += camera.forward * direction.z
    camera.position += camera.right * direction.x
    camera.position += camera.up * direction.y
}

rotate_camera :: proc(camera: ^Camera, yaw: f32, pitch: f32, roll: f32) {
    if (camera.is_locked) {
        camera.up = camera.world_up
    }

    // Yaw
    quat := glm.quatAxisAngle(camera.up, -yaw)
    camera.forward = glm.normalize(glm.quatMulVec3(quat, camera.forward))
    camera.right = glm.normalize(glm.cross(camera.forward, camera.up))

    // Pitch
    quat = glm.quatAxisAngle(camera.right, -pitch)
    forward := glm.normalize(glm.quatMulVec3(quat, camera.forward))

    if !camera.is_locked || abs(glm.dot(forward, camera.up)) < 0.99 {
        camera.forward = forward
    }

    // Roll
    if (!camera.is_locked && roll != 0) {
        quat = glm.quatAxisAngle(camera.forward, -roll)
        camera.right = glm.normalize(glm.quatMulVec3(quat, camera.right))
    }

    camera.up = glm.normalize(glm.cross(camera.right, camera.forward))
}

point_camera_at :: proc(camera: ^Camera, point: glm.vec3) {
    if glm.distance(camera.position, point) < glm.F32_EPSILON {
        return
    }

    if (camera.is_locked) {
        camera.up = camera.world_up
    }

    camera.forward = glm.normalize(point - camera.position)
    camera.right = glm.normalize(glm.cross(camera.forward, camera.up))
    camera.up = glm.normalize(glm.cross(camera.right, camera.forward))
}

lock_camera :: proc(camera: ^Camera) {
    camera.is_locked = true
    camera.world_up = camera.up
}

unlock_camera :: proc(camera: ^Camera) {
    camera.is_locked = false
}

compute_camera_projection :: proc(camera: ^Camera, aspect: f32) {
    camera.projection = glm.mat4Perspective(glm.radians(camera.fov), aspect, camera.near, camera.far)
}

compute_camera_view :: proc(camera: ^Camera) {
    camera.view = glm.mat4LookAt(camera.position, camera.position + camera.forward, camera.up)
}

Camera_Movement :: struct {
    move_speed: f32,
    zoom_speed: f32,
    yaw_speed: f32,
    pitch_speed: f32,
    roll_speed: f32,
}

Camera_Input :: struct {
    left: bool,
    right: bool,
    backward: bool,
    forward: bool,
}

input_fly_camera :: proc(camera: ^Camera, input: Camera_Input, speed: f32) {
    if input.left {
        move_camera(camera, {-speed, 0, 0})
    }

    if input.right {
        move_camera(camera, {speed, 0, 0})
    }

    if input.backward {
        move_camera(camera, {0, 0, -speed})
    }

    if input.forward {
        move_camera(camera, {0, 0, speed})
    }
}
