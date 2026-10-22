extends CharacterBody2D
class_name Player
@export var speed := 220.0
var can_move := true

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12.0
	collider.shape = shape
	add_child(collider)
	var body := ColorRect.new()
	body.color = Color("#e8c9a0")
	body.size = Vector2(24, 36)
	body.position = Vector2(-12, -30)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	var lantern := ColorRect.new()
	lantern.color = Color("#ffd466")
	lantern.size = Vector2(9, 10)
	lantern.position = Vector2(12, -16)
	lantern.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lantern)

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed if can_move else Vector2.ZERO
	move_and_slide()
