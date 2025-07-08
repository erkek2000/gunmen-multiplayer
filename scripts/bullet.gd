extends CharacterBody2D


const SPEED = 400.0
var direction: Vector2

func _ready():
	direction = Vector2(1,0).rotated(rotation)

func _physics_process(delta):
	
	velocity = SPEED * direction
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 1 * delta


	move_and_slide()
