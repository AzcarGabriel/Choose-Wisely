extends CanvasLayer

export var start_sound: AudioStream
export var quit_sound: AudioStream

onready var game = get_parent().get_parent()

var mouse_entered = false

func _ready():
	$MainBoxContainer/BasicGame.connect("pressed", self, "on_start_basic_game")
	$MainBoxContainer/HardGame.connect("pressed", self, "on_start_hard_game")
	$MainBoxContainer/Configuration.connect("pressed", self, "on_change_menu")
	$MainBoxContainer/Credits.connect("pressed", self, "on_credits")
	$MainBoxContainer/Quit.connect("pressed", self, "on_quit")
	$AudioBoxContainer/Return.connect("pressed", self, "on_change_menu")
	$AudioBoxContainer/MainMusicSlider.connect("value_changed", self, "main_slider_value_change")
	$AudioBoxContainer/EffectsSlider.connect("mouse_entered", self, "effects_slider_mouse_entered")
	$AudioBoxContainer/EffectsSlider.connect("mouse_exited", self, "effects_slider_mouse_exited")
	$CreditsContainer/Return.connect("pressed", self, "on_credits")

func on_start_basic_game():
	AudioManager.play(start_sound, "Effects")
	game.change_scene("basic_game")
	
func on_start_hard_game():
	AudioManager.play(start_sound, "Effects")
	game.change_scene("hard_game")
	
func on_change_menu():
	AudioManager.play(start_sound, "Effects")
	$MainBoxContainer.visible = !$MainBoxContainer.visible
	$AudioBoxContainer.visible = !$AudioBoxContainer.visible

func on_credits():
	AudioManager.play(start_sound, "Effects")
	$MainBoxContainer.visible = !$MainBoxContainer.visible
	$CreditsContainer.visible = !$CreditsContainer.visible
	
func on_quit():
	AudioManager.play(quit_sound, "Effects")
	yield(AudioManager, "finished")
	get_tree().quit()

func main_slider_value_change(value: float):
	AudioManager.change_volume("main", value)
	
func effects_slider_mouse_entered():
	mouse_entered = true

func effects_slider_mouse_exited():
	mouse_entered = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed and mouse_entered:
		AudioManager.change_volume("effect", $AudioBoxContainer/EffectsSlider.value)
		AudioManager.play(start_sound, "Effects")
