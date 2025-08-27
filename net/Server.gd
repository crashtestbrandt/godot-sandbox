## res://net/Server.gd

class_name Server
extends Node

var peer: MultiplayerPeer
var tick_timer: Timer
var snapshot_timer: Timer
var ephemeral := false
var _client_count := 0

func start(kv: Dictionary) -> void:
	ephemeral = str(kv.get("ephemeral", "0")) != "0"

	var en := ENetMultiplayerPeer.new()
	var port := int(kv.get("port", NetConfig.DEFAULT_PORT))
	var maxc := int(kv.get("max_clients", NetConfig.MAX_CLIENTS))
	var err := ERR_CANT_CREATE
	for i in range(5): # try up to 5 ports: port, port+1, ...
		err = en.create_server(port + i, maxc)
		if err == OK:
			if i != 0:
				print("ENet server bound to fallback port ", port + i)
			port += i
			break
	if err != OK:
		push_error("ENet server failed to bind (last err=%d). Is another DS running?" % err)
		return
	peer = en
	get_tree().get_multiplayer().multiplayer_peer = peer

	# Load world (server runs headless fine)
	var map_path := str(kv.get("map", NetConfig.DEFAULT_MAP))
	var world: Node3D = load(map_path).instantiate()
	add_child(world)

	# Simple spawner
	var spawner := preload("res://net/SpawnService.gd").new()
	add_child(spawner)

	# Connect signals on the MultiplayerAPI
	var mp := get_tree().get_multiplayer()
	mp.peer_connected.connect(_on_peer_connected)
	mp.peer_disconnected.connect(_on_peer_disconnected)

	# Tick & snapshot timers
	tick_timer = Timer.new()
	tick_timer.wait_time = 1.0 / NetConfig.TICK_HZ
	tick_timer.autostart = true
	tick_timer.timeout.connect(_tick)
	add_child(tick_timer)

	snapshot_timer = Timer.new()
	snapshot_timer.wait_time = 1.0 / NetConfig.SNAPSHOT_HZ
	snapshot_timer.autostart = true
	snapshot_timer.timeout.connect(_snapshot)
	add_child(snapshot_timer)

func _on_peer_connected(id: int) -> void:
		_client_count += 1
		get_node("SpawnService").server_spawn_pawn_for(id)

func _on_peer_disconnected(id: int) -> void:
	_client_count = max(0, _client_count - 1)
	get_node("SpawnService").server_despawn_pawn_for(id)
	if ephemeral and _client_count == 0:
		# give a tiny grace period in case the host is just relaunching
		await get_tree().create_timer(0.25).timeout
		if _client_count == 0:
			get_tree().quit()

func _tick() -> void:
	pass

func _snapshot() -> void:
	pass

@rpc("any_peer", "reliable")
func _rpc_admin_quit():
	# In a real game, check that the caller is the host/admin!
	# Call with rpc_id(1, "_rpc_admin_quit")
	get_tree().quit()
