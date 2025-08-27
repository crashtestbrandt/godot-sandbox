# Godot Sandbox

For exploring and demonstrating concepts in Godot 4.4.

## Launch Examples

Dedicated server (ENet):

```
godot4 --headless --path . -- --mode=server --transport=enet --port=27015 --map=res://world/TestWorld.tscn
```

Client to localhost (ENet):

```
godot4 --path . -- --mode=client --transport=enet --connect=127.0.0.1:27015 --map=res://world/TestWorld.tscn
```

“Host” convenience (spawn local DS then connect):

```
godot4 --path . -- --mode=bootstrap --transport=enet --port=27015 --map=res://world/TestWorld.tscn
```

Accepted User Flags:

```
--mode=server|client|bootstrap
--ephemeral
--transport=enet|steam
--port=NNNN
--connect=HOST:PORT
--max_clients=N
--map=res://world/TestWorld.tscn
```

## Repo Structure

```
project.godot
autoload/
  Bootstrap.gd
  NetConfig.gd
net/
  Server.gd
  Client.gd
  SpawnService.gd
player/
  PlayerPawn.tscn
  PlayerPawn.gd
world/
  TestWorld.tscn
```

