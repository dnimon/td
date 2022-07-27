extends Node2D

signal ability_complete(enemies, type)

var type
var category
var built
var built_detected
var enemy_array = []

func _ready():
	if type:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]
		
func _physics_process(_delta):
	if not built_detected and built:
		built_detected = true
		run_ability()
		
func run_ability():
	get_node("Range/Sprite").visible = false
	get_node("Range/AnimatedSprite").visible = true
	get_node("Range/AnimatedSprite").playing = true
	get_node("Range/CollisionShape2D/AudioStreamPlayer2D").play()
	
func _on_AudioStreamPlayer2D_finished():
	queue_free()

func _on_AnimatedSprite_animation_finished():
	get_node("Range/AnimatedSprite").visible = false
	emit_signal('ability_complete', enemy_array, type)

func _on_Range_body_entered(body):
	if built:
		enemy_array.append(body.get_parent())

func _on_Range_body_exited(body):
	if built:
		enemy_array.erase(body.get_parent())
