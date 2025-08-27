## res://net/Client.gd

class_name Client
extends Node

var peer: MultiplayerPeer

func start(kv: Dictionary) -> bool:
	var hp := str(kv.get("connect", "127.0.0.1:27015")).split(":")
	if hp.size() != 2: push_error("Bad --connect"); return false
	var host := hp[0]
	var port := int(hp[1])

	var en := ENetMultiplayerPeer.new()
	var err := en.create_client(host, port)
	if err != OK:
		push_error("ENet client connect failed (err=%d)" % err)
		return false
	peer = en
	var mp: MultiplayerAPI = get_tree().get_multiplayer()
	mp.multiplayer_peer = peer

	var map_path := str(kv.get("map", NetConfig.DEFAULT_MAP))
	var world: Node3D = load(map_path).instantiate()

	# 1) The current scene must be a direct child of the root.
	get_tree().root.add_child(world)
	get_tree().set_current_scene(world)

	# 2) Ensure a camera; use look_at_from_position() so it works immediately.
	var cam := world.get_node_or_null("Camera3D")
	if cam is Camera3D:
		cam.make_current()
	else:
		var fc := Camera3D.new()
		world.add_child(fc)
		fc.look_at_from_position(Vector3(0, 3, 6), Vector3.ZERO, Vector3.UP)
		fc.make_current()

	return true
