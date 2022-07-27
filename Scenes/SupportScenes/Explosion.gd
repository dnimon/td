extends AnimatedSprite

func _ready():
	_set_playing(true)

func _on_ProjectileImpact_animation_finished():
	self.visible = false


func _on_AudioStreamPlayer_finished():
	queue_free()
