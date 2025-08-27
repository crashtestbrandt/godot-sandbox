## res://net/SpawnService.gd

class_name SpawnService
extends Node

var pawn_scene := preload("res://player/PlayerPawn.tscn")
var pawns := {} # peer_id -> Node

func server_spawn_pawn_for(peer_id: int) -> void:
    if not get_tree().multiplayer.is_server(): return
    var pawn := pawn_scene.instantiate()
    add_child(pawn)
    pawns[peer_id] = pawn
    # Authority stays with the server (default = peer 1). Do NOT reassign here.

func server_despawn_pawn_for(peer_id: int) -> void:
    if pawns.has(peer_id):
        pawns[peer_id].queue_free()
        pawns.erase(peer_id)
