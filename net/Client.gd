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
    get_tree().multiplayer.multiplayer_peer = peer

    var map_path := str(kv.get("map", NetConfig.DEFAULT_MAP))
    var world: Node3D = load(map_path).instantiate()
    add_child(world)
    return true
