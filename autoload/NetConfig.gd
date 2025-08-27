## res://autoload/NetConfig.gd

class_name NetConfigSingleton
extends Node

const DEFAULT_MAP := "res://world/TestWorld.tscn"
const DEFAULT_PORT := 27015
const MAX_CLIENTS := 8
const TICK_HZ := 60.0
const SNAPSHOT_HZ := 15.0

var cfg: Dictionary = {}
