extends Node

signal finished

var main_volume = 0
var effect_volume = 0

onready var main_bus_index = AudioServer.get_bus_index("Music")
onready var effect_bus_index = AudioServer.get_bus_index("Effects")

func play(stream: AudioStream, bus: String):
	var player = AudioStreamPlayer.new()
	player.bus = bus
	add_child(player)
	player.stream = stream
	player.play()
	yield(player, "finished")
	remove_child(player)
	player.queue_free()
	emit_signal("finished")

func change_volume(bus_name: String, value: int):
	# Rango de trabajo entre -20 y 0, por lo tanto hay que transfomar
	var real_value = -0.2 * (100 - value)
	var mute = real_value <= -19
	
	var index = ''
	if bus_name == "main":
		main_volume = real_value
		index = main_bus_index
	elif bus_name == "effect":
		effect_volume = real_value
		index = effect_bus_index
	
	if not mute:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, real_value)
	else:
		AudioServer.set_bus_mute(index, true)
