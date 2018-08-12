extends Node2D

onready var Grid = get_parent()
onready var _person_top = get_child(0)
onready var _person_bottom = get_child(1)

var _timer = null
var _input_direction = null 

func _ready():
	_timer = Timer.new()
	
	add_child(_timer)
	_timer.connect("timeout", self, "drop_down")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false)
	_timer.start()
	
	update_look_direction(Vector2(1, 0))


func _process(delta):
	rotate_person()
	
	_input_direction = get_input_direction()
	if not _input_direction:
		return
	_input_direction = Vector2(_input_direction.x, 0)
	update_look_direction(_input_direction)
	
	var top_target_position = Grid.request_move(_person_top, _input_direction)
	var bottom_target_position = Grid.request_move(_person_bottom, _input_direction)
	if top_target_position && bottom_target_position:
		move_person(_person_top, top_target_position)
		move_person(_person_bottom, bottom_target_position)


func rotate_person():
	var rotation_direction = get_rotation_direction()
	if rotation_direction == null: 
		return

	set_process(false)
	_timer.stop()
	
	var top_target_position = Grid.request_move(_person_top, 
			rotation_from_orientation(Grid.get_person_orientation(_person_top, _person_bottom), rotation_direction))
	if top_target_position:
		move_person(_person_top, top_target_position)
		
	set_process(true)
	_timer.start()
	

func rotation_from_orientation(orientation, direction):
	match Grid.get_person_orientation(_person_top, _person_bottom):
		0:
			# left from up
			if direction == 0:
				return(Vector2(-1, 1))
			# right from up
			else:
				return(Vector2(1, 1))
		1:
			# left from down
			if direction == 0:
				return(Vector2(1, -1))
			# right from down
			else:
				return(Vector2(-1, -1))
		2:
			# left from right
			if direction == 0:
				return(Vector2(-1, -1))
			# right from right
			else:
				return(Vector2(-1, 1))
		3:
			# left from left
			if direction == 0:
				return(Vector2(1, 1))
			# right from left
			else:
				return(Vector2(1, -1))
			
func drop_down():
	var bottom_target_position = Grid.request_move(_person_bottom, Vector2(0, 1))
	if bottom_target_position:
		move_person(_person_bottom, bottom_target_position)
		
	var top_target_position = Grid.request_move(_person_top, Vector2(0, 1))
	if top_target_position:
			move_person(_person_top, top_target_position)

func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func get_rotation_direction():
	if Input.is_action_just_pressed("rotate_left"): 
		return(0)
	elif Input.is_action_just_pressed("rotate_right"): 
		return(1)

func update_look_direction(direction):
	print("dir")
	#$Pivot/Sprite.rotation = 0#direction.angle()


func move_person(pawn, target_position):
	pawn.position = target_position