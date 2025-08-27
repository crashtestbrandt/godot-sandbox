## res://player/PlayerPawn.gd

class_name PlayerPawn
extends CharacterBody3D

const SPEED := 6.0
const GRAV := 18.0
const MOUSE_SENS := 0.003

var yaw := 0.0
var pitch := 0.0
var _mouse_delta := Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Clients accumulate mouse delta locally
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		_mouse_delta += e.relative

func _physics_process(_dt: float) -> void:
	if name != "Pawn_%d" % get_tree().get_multiplayer().get_unique_id():
		return
	# Only the local player should push inputs
	if is_multiplayer_authority():
		var move := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
		)
		var jump := Input.is_action_pressed("jump")
		var look := _mouse_delta
		_mouse_delta = Vector2.ZERO
		# Server ID is always 1 in HL multiplayer.
		rpc_id(1, "_rpc_input", Engine.get_physics_frames(), move, look, jump)

# Server receives inputs from any peer and moves the pawn.
@rpc("any_peer", "unreliable_ordered")
func _rpc_input(tick: int, move: Vector2, look: Vector2, jump: bool) -> void:
	if not get_tree().get_multiplayer().is_server(): return

	# Look
	yaw += look.x * MOUSE_SENS
	pitch = clamp(pitch - look.y * MOUSE_SENS, -1.3, 1.3)
	rotation.y = yaw
	if has_node("Camera3D"):
		$Camera3D.rotation.x = pitch

	# Move
	var f := -transform.basis.z
	var r := transform.basis.x
	var v2 := (r * move.x + f * move.y) * SPEED
	velocity.x = v2.x
	velocity.z = v2.z
	if is_on_floor():
		velocity.y = 6.5 if jump else 0.0
	else:
		velocity.y -= GRAV * get_physics_process_delta_time()

	move_and_slide()
