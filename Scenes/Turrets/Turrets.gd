extends Node2D

signal accept_click()
signal cancel_click()

var type
var category
var enemy_array = []
var built = false
var enemy
var ready = true
var first_click = true
var from_upgrade

var fired_missile = preload("res://Scenes/SupportScenes/FiredMissile.tscn")

var timer
var missile_timer
var missile_reloading_timer

func _ready():
	setup_timers()
	
	if from_upgrade:
		first_click = false
	if type:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"]

func _physics_process(_delta):
	if enemy_array.size() != 0 and built:
		select_enemy()
		
		var shouldTurn = true
		if get_node_or_null("AnimationPlayer") and get_node_or_null("AnimationPlayer").is_playing():
			shouldTurn = false

		if shouldTurn:
			turn()
		if ready:
			fire()
	else:
		cease_fire_custom()
		enemy = null

func turn():
	if not is_instance_valid(enemy):
		enemy = null
		return
	
	get_node("Turret").look_at(enemy.position)

func select_enemy():
	var enemy_progress_array = []
	for i in enemy_array:
		if not is_instance_valid(i):
			enemy_array.erase(i)
			continue
		enemy_progress_array.append(i.offset)
		var max_offset = enemy_progress_array.max() #close to path
		var enemy_index = enemy_progress_array.find(max_offset)
		enemy = enemy_array[enemy_index]
		
func fire():
	if not timer.is_stopped():
		return
	ready = false
	if category == "Custom":
		timer.start(GameData.tower_data[type]["rof"]); yield(timer, "timeout")
		fire_custom()
	elif category == "Projectile":
		fire_gun()
		timer.start(GameData.tower_data[type]["rof"]); yield(timer, "timeout")
	elif category == "Missile":
		timer.start(GameData.tower_data[type]["rof"] / 2); yield(timer, "timeout")
		fire_missile()
	ready = true
	
func fire_gun():
	enemy.on_hit(GameData.tower_data[type]["damage"], GameData.tower_data[type]["sound"])
	get_node("AnimationPlayer").play("Fire")
	
func fire_custom():
	for i in get_node("Turret").get_children():
		if i.get_node_or_null("Fire"):
			i.get_node_or_null("Fire").fire()
			
func cease_fire_custom():
	for i in get_node("Turret").get_children():
		if i.get_node_or_null("Fire"):
			i.get_node_or_null("Fire").cease_fire()

func fire_missile():
	var picked_missile
	var missiles = []
	for i in get_node("Turret").get_children():
		if i.is_in_group("missile"):
			missiles.append(i)

	var reloading = false
	if not missiles[missiles.size() - 1].visible:
		reloading = true
	
	if reloading:
		missile_reloading_timer.start(GameData.tower_data[type]["rof"]); yield(missile_reloading_timer, "timeout")
		return
		
	for i in missiles:
		if i.visible:
			picked_missile = i
			i.visible = false
			var new_missile = fired_missile.instance()
			new_missile.position = i.position
			new_missile.connect("missile_impact", self, "missile_impacted")
			get_node("Turret").add_child(new_missile)
			break
		
	missile_timer.start(GameData.tower_data[type]["rof"]); yield(missile_timer, "timeout")
	if picked_missile and is_instance_valid(picked_missile):
		picked_missile.visible = true
	
	
func missile_impacted(impact_enemy):
	if not is_instance_valid(impact_enemy):
		impact_enemy = null
		return

	if impact_enemy:
		impact_enemy.on_hit(GameData.tower_data[type]["damage"], GameData.tower_data[type]["sound"])

func _on_Range_body_entered(body):
	if built:
		enemy_array.append(body.get_parent())

func _on_Range_body_exited(body):
	if built:
		enemy_array.erase(body.get_parent())
		
func _on_Fire_collided(fire_enemy):
	if not is_instance_valid(fire_enemy):
		return
	fire_enemy.on_hit(GameData.tower_data[type]["damage"], GameData.tower_data[type]["sound"])

func accept_clicked():
	if built:
		if first_click:
			first_click = false
			return
		emit_signal('accept_click')
	
func cancel_clicked():
	if built:
		if first_click:
			first_click = false
			return
		emit_signal('cancel_click')
		
func setup_timers():
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)
	
	missile_timer = Timer.new()
	missile_timer.one_shot = true
	missile_timer.autostart = false
	add_child(missile_timer)
	
	missile_reloading_timer = Timer.new()
	missile_reloading_timer.one_shot = true
	missile_reloading_timer.autostart = false
	add_child(missile_reloading_timer)
