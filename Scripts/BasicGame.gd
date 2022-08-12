extends Node2D

class SideShape:
	var shape: String
	var color: String
	var side: String

class ShapePair:
	var right: SideShape
	var wrong: SideShape

var MAX_ROUNDS = 35

var shape_path = "res://Scenes/Shape.tscn"

var shape_options = ["circle", "square", "triangle", "star"]
var shape_dict = {
	"circle": preload("res://Assets/Shapes/Circle.png"),
	"square": preload("res://Assets/Shapes/Square.png"),
	"triangle": preload("res://Assets/Shapes/Triangle.png"),
	"star": preload("res://Assets/Shapes/Star.png")
}

var shape_colors_options = ["blue", "red", "green", "yellow"]
var shape_colors_dict = {
	"blue": Color.blue,
	"red": Color.red,
	"green": Color.green,
	"yellow": Color.yellow
}

onready var game = get_parent().get_parent()
onready var left_spawn_position = $LeftSpawn.position
onready var right_spawn_position = $RightSpawn.position
var position_options = ["left", "right"]

var last_shape_indexes = [] # Para evitar repeticiones
var actualPair: ShapePair
var actual_shapes = []

var available_times = [4.0, 3.0, 2.0]
var actual_time_index = 0

var playing = false
var correct_answers = 0
var score = 0
var rounds = 0
var color_wise = false
var rotation_enabled = false

func _ready():
	$Timer.connect("timeout", self, "timeout")
	$Timer.wait_time = available_times[actual_time_index]
	$CanvasLayer/Score.bbcode_text = "[center]Score: %d[/center]" % score
	$CanvasLayer/ReturnToMainMenu.connect("pressed", self, "return_to_main_menu")
	randomize()

func _physics_process(delta) -> void:
	if rounds < MAX_ROUNDS:
		if !playing:
			setup()
			playing = true
			rounds += 1
			if 20 == rounds:
				rotation_enabled = true
				shape_options.erase("circle")
				shape_dict.erase("circle")
			if 10 == rounds:
				color_wise = true
				actual_time_index += 1
			if 3 < rounds:
				$CanvasLayer/Time.visible = true
				$Timer.wait_time = available_times[actual_time_index]
				$Timer.start()
		else:
			$CanvasLayer/Time.bbcode_text = "[center]%1.1f[/center]" % $Timer.time_left
			if Input.is_action_just_pressed("ui_right"):
				check_answer("right")
			
			if Input.is_action_just_pressed("ui_left"):
				check_answer("left")
	else:
		clean_actual_pair()
		$CanvasLayer/Instruction.visible = false
		$CanvasLayer/Time.visible = false
		$CanvasLayer/Score.visible = false
		$CanvasLayer/ReturnToMainMenu.visible = true
		$CanvasLayer/FinalResults.bbcode_text = "[center]Final results:\nScore: %d\nCorrect answers: %d/%d[/center]" % [score, correct_answers, rounds] 
		$CanvasLayer/FinalResults.visible = true
		$Timer.stop()

# Game logic
func check_answer(side: String) -> void:
	var result = actualPair.right.side == side
	if result:
		$CorrectSound.play()
		correct_answers += 1
		score += calculate_score()
		$CanvasLayer/Score.bbcode_text = "[center]Score: %d[/center]" % score
	else:
		$IncorrectSound.play()
	playing = false

func calculate_score() -> int:
	if 1.2 > $Timer.wait_time - $Timer.time_left:
		return 10
	elif 0 != $Timer.time_left:
		return int(10 * $Timer.time_left / available_times[actual_time_index])
	return 10

func timeout() -> void:
	playing = false
	$IncorrectSound.play()

func return_to_main_menu() -> void:
	game.change_scene("main_menu")

# Actual pair decision and graphics
func setup() -> void:
	var first_index = null
	var second_index = null
	var init = true
	while init or (first_index in last_shape_indexes and second_index in last_shape_indexes):
		first_index = randi() % shape_options.size()
		second_index = randi() % shape_options.size()
		while first_index == second_index:
			second_index = randi() % shape_options.size()
		init = false

	var first_shape = shape_options[first_index]
	var second_shape = shape_options[second_index]

	var first_color = ""
	var second_color = ""
	if color_wise:
		var first_color_index = randi() % shape_colors_options.size()
		var second_color_index = randi() % shape_colors_options.size()
		while first_color_index == second_color_index:
			second_color_index = randi() % shape_colors_options.size()
			
		first_color = shape_colors_options[first_color_index]
		second_color = shape_colors_options[second_color_index]
	
	clean_actual_pair()
	position_options.shuffle()
	spawn(first_shape, first_color, position_options[0])
	spawn(second_shape, second_color, position_options[1])
	update_actual_pair(first_shape, first_color, position_options[0], second_shape, second_color, position_options[1])
	last_shape_indexes = [first_index, second_index]
	create_instruction()

func update_actual_pair(first_shape: String, first_color: String, first_side: String, second_shape: String, second_color: String, second_side: String) -> void:
	actualPair = ShapePair.new()
	
	var first = SideShape.new()
	first.shape = first_shape
	first.color = first_color
	first.side = first_side
	
	var second = SideShape.new()
	second.shape = second_shape
	second.color = second_color
	second.side = second_side
	
	var percent = randf()
	if 0.5 < percent:
		actualPair.right = first
		actualPair.wrong = second
	else:
		actualPair.right = second
		actualPair.wrong = first

func clean_actual_pair() -> void:
	actualPair = null
	while actual_shapes.size() != 0:
		actual_shapes.pop_front().queue_free()

func spawn(shape: String, color: String, side: String) -> void:
	var shape_object = load(shape_path).instance()
	shape_object.set_shape_sprite(shape_dict[shape])
	if color:
		shape_object.set_color(shape_colors_dict[color])
	
	if side == "left":
		shape_object.set_position(left_spawn_position)
	elif side == "right":
		shape_object.set_position(right_spawn_position)
	
	if rotation_enabled:
		var direction = 1.0 if randi() % 100 < 50 else -1.0
		shape_object.enable_rotation(direction)

	add_child(shape_object)
	actual_shapes.append(shape_object)

func create_instruction() -> void:
	var affirmative =  true if randf() > 0.5 else false
	var instruction = ""
	var available_colors = []
	if color_wise:
		available_colors = [actualPair.right.color, actualPair.wrong.color]
		available_colors.shuffle()
	if affirmative:
		instruction += "Select the "
		if color_wise:
			instruction += "[color=%s]%s[/color] %s" % [available_colors[0], actualPair.right.color, actualPair.right.shape]
		else:
			instruction += actualPair.right.shape
	else:
		instruction += "Do not select the "
		if color_wise:
			instruction += "[color=%s]%s[/color] %s" % [available_colors[0], actualPair.wrong.color, actualPair.wrong.shape]
		else:
			instruction += actualPair.wrong.shape
	
	# Select the COLOR SHAPE | Do not select the COLOR SHAPE
	$CanvasLayer/Instruction.bbcode_text = "[center]%s[/center]" % [instruction]
