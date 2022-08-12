extends Node2D

var degrees_per_second = 0.0

func set_color(color: Color):
	$Sprite.modulate = color

func set_shape_sprite(texture: Texture):
	$Sprite.set_texture(texture)

func _physics_process(delta):
	if 0 != degrees_per_second:
		rotate(delta * deg2rad(degrees_per_second))

func enable_rotation(direction = 1.0):
	degrees_per_second = 180.0 * direction
