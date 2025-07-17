extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var playerName : String = ""
@export var bullet: PackedScene

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	$PlayerNameLabel.text = playerName

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		$GunRotation.look_at(get_viewport().get_mouse_position())
		
		if Input.is_action_just_pressed("Fire"):
			fire.rpc()
		
		# Handle jump.
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("Move Left", "Move Right")
		if direction:
			velocity.x = direction * SPEED
			$AnimatedSprite2D.play("run")
		else:
			$AnimatedSprite2D.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
@rpc("any_peer","call_local")
func fire():
	var a_bullet = bullet.instantiate()
	a_bullet.global_position = $GunRotation/BulletSpawn.global_position
	a_bullet.rotation_degrees = $GunRotation.rotation_degrees
	get_tree().root.add_child(a_bullet)
	
