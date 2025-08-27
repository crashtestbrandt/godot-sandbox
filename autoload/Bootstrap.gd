## res://autoload/Bootstrap.gd

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
		"--", "--mode=server", "--transport=enet",
		"--port=%d" % port, "--map=%s" % map,
		"--ephemeral=1" # <— new
	]

	var pid := OS.create_process(exe, args) # non-blocking in 4.4; returns PID or -1
	if pid == -1:
		push_error("Bootstrap: failed to start DS process")
		return

	# Give the DS a moment to bind, then connect
	await get_tree().create_timer(0.15).timeout
	_connect_local_with_timeout(port, map, 5.0)

func _connect_local_with_timeout(port: int, map: String, seconds: float) -> void:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if _try_connect_local(port, map):
			return
		await get_tree().create_timer(0.25).timeout
	push_error("Bootstrap: failed to connect to local DS on port %d" % port)

func _try_connect_local(port: int, map: String) -> bool:
	var client := preload("res://net/Client.gd").new()
	add_child(client)
	var ok := client.start({"transport": "enet", "connect": "127.0.0.1:%d" % port, "map": map})
	if not ok:
		client.queue_free()
	return ok
