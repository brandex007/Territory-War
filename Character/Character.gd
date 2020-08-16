# Simple K2D character for testing/demos
extends KinematicBody2D

signal collided

export var gravity = 2500
export var speed = 400
export var jump = -900

var jumping = false
var velocity = Vector2()

onready var sprite = $Sprite
onready var gun = sprite.get_node(@"Gun")

onready var shoot_timer = $ShootAnimation
onready var animation_player = $AnimationPlayer

export(String) var action_suffix = ""
var is_shooting = false

var direction = 1

func get_input():
	velocity.x = 0
	jumping = false
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
		if direction == -1:
			ChangeDirection()

	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
		if direction == 1:
			ChangeDirection()
	velocity.x *= speed
	if Input.is_action_just_pressed('ui_up'):
		jumping = true
		
	if Input.is_action_just_pressed('ui_select'):
		is_shooting = gun.shoot(direction)
	
func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	velocity = move_and_slide(velocity, Vector2(0, -1))
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal('collided', collision)

	if is_on_floor() and jumping:
		velocity.y = jump
		
	var animation = get_new_animation(is_shooting)
	if shoot_timer.is_stopped():
		if is_shooting:
			shoot_timer.start()
		#animation_player.play(animation)
		
func get_new_animation(is_shooting = false):
	var animation_new = ""
	if is_on_floor():
		animation_new = "run" if abs(velocity.x) > 0.1 else "idle"
	else:
		animation_new = "falling" if velocity.y > 0 else "jumping"
	if is_shooting:
		animation_new += "_weapon"
	return animation_new
		
func ChangeDirection():
	if direction == -1:
		get_node( "Sprite" ).set_flip_h( false )
		sprite.scale.x = 1
		direction = 1
	elif direction == 1:
		sprite.scale.x = -1
		direction = -1
		

