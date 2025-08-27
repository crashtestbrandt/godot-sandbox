## res://net/Server.gd

class_name Server
extends Node

var peer: MultiplayerPeer
var tick_timer: Timer
var snapshot_timer: Timer

func start(kv: Dictionary) -> void:
    var port := int(kv.get("port", NetConfig.DEFAULT_PORT))
    var maxc := int(kv.get("max_clients", NetConfig.MAX_CLIENTS))

    var en := ENetMultiplayerPeer.new()
    var err := en.create_server(port, maxc)
    if err != OK:
        push_error("ENet server failed on port %d (err=%d)" % [port, err])
        return
    peer = en
    get_tree().multiplayer.multiplayer_peer = peer

    # Load world (server runs headless fine)
    var map_path := str(kv.get("map", NetConfig.DEFAULT_MAP))
    var world: Node3D = load(map_path).instantiate()
    add_child(world)

    # Simple spawner
    var spawner := preload("res://net/SpawnService.gd").new()
    add_child(spawner)

    # Connect signals on the MultiplayerAPI
    var mp: MultiplayerAPI = get_tree().multiplayer
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
    get_node("SpawnService").server_spawn_pawn_for(id)

func _on_peer_disconnected(id: int) -> void:
    get_node("SpawnService").server_despawn_pawn_for(id)

func _tick() -> void:
    pass

func _snapshot() -> void:
    pass
