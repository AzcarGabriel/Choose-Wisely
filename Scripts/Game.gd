extends Node

var levels = {
	"main_menu": "res://Scenes/MainMenu.tscn",
	"basic_game": "res://Scenes/BasicGame.tscn",
	"hard_game": "res://Scenes/HardGame.tscn"
}

var current_level = "main_menu"
var current_scene: Node = null

var playing = false

func _ready() -> void:
	change_scene(current_level)
	playing = true

func change_scene(path: String):
	if current_scene:
		$World.remove_child(current_scene)
		current_scene.queue_free()
	var new_scene = load(levels[path]).instance()
	$World.add_child(new_scene)
	current_scene = new_scene
