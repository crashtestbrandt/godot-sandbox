## res://autoload/Bootstap.gd

class_name BootstrapSingleton
extends Node

func _ready() -> void:
    var kv := _parse_user_args(OS.get_cmdline_user_args())
    NetConfig.cfg = kv
    match str(kv.get("mode", "client")):
        "server": _start_server(kv)
        "client": _start_client(kv)
        "bootstrap": _start_bootstrap(kv)
        _: push_error("Unknown --mode")

func _parse_user_args(a: PackedStringArray) -> Dictionary:
    var d := {}
    for s in a:
        if s.begins_with("--"):
            var t := s.substr(2)
            var eq := t.find("=")
            if eq >= 0: d[t.substr(0, eq)] = t.substr(eq + 1)
            else: d[t] = true
    return d

func _start_server(kv: Dictionary) -> void:
    var server := preload("res://net/Server.gd").new()
    add_child(server)
    server.start(kv)

func _start_client(kv: Dictionary) -> void:
    var client := preload("res://net/Client.gd").new()
    add_child(client)
    client.start(kv)

func _start_bootstrap(kv: Dictionary) -> void:
    var port := int(kv.get("port", NetConfig.DEFAULT_PORT))
    var map := str(kv.get("map", NetConfig.DEFAULT_MAP))
    var exe := OS.get_executable_path()
    var args := [
        "--headless", "--path", ProjectSettings.globalize_path("res://"),
        "--", "--mode=server", "--transport=enet", "--port=%d" % port, "--map=%s" % map
    ]
    # Non-blocking spawn: third parameter = blocking (false) → returns PID.
    OS.execute(exe, args) # we don't need the PID for this PoC

    # Try to connect to localhost until the DS binds
    var deadline := Time.get_ticks_msec() + 5000
    while Time.get_ticks_msec() < deadline:
        if _try_connect_local(port, map): return
        await get_tree().create_timer(0.25).timeout
    push_error("Bootstrap: failed to connect to local DS on port %d" % port)

func _try_connect_local(port: int, map: String) -> bool:
    var client := preload("res://net/Client.gd").new()
    add_child(client)
    return client.start({"transport": "enet", "connect": "127.0.0.1:%d" % port, "map": map})
