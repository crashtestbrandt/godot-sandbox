## res://net/SpawnService.gd

class_name SpawnService
extends Node

var pawn_scene := preload("res://player/PlayerPawn.tscn")
var pawns := {} # peer_id -> Node

func server_spawn_pawn_for(peer_id: int) -> void:
    var pawn := pawn_scene.instantiate()
    pawn.name = "Pawn_%d" % peer_id # simple tag for PoC
    add_child(pawn)
    pawns[peer_id] = pawn
    rpc_id(peer_id, "_rpc_client_spawn", peer_id)

func server_despawn_pawn_for(peer_id: int) -> void:
    if pawns.has(peer_id):
        pawns[peer_id].queue_free()
        pawns.erase(peer_id)

@rpc("authority", "reliable")
func _rpc_client_spawn(peer_id: int) -> void:
    if get_tree().get_multiplayer().get_unique_id() != peer_id:
        return
    var pawn := preload("res://player/PlayerPawn.tscn").instantiate()
    pawn.name = "Pawn_%d" % peer_id
    get_tree().current_scene.add_child(pawn)
    var cam := pawn.get_node_or_null("Camera3D")
    if cam is Camera3D:
        cam.make_current()
