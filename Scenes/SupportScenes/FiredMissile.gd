extends Area2D

signal missile_impact(enemy, missle)

var velocity = Vector2(350, 0)

func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation = velocity.angle()

func _on_Area2D_body_entered(body):
	var parent = body.get_parent()
	if parent.is_in_group("enemy"):
		emit_signal("missile_impact", parent)
	queue_free()
