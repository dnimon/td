extends Node

signal setting_updated(setting_key, setting_value)

var settings = {
	"time_between_waves": 10,
	"show_fps_monitor": false,
	"starting_money": 1000,
	"starting_base_health": 100,
	"starting_map": "Map1",
	"main_menu_map": "MainMenuMap",
	"map_order": {
		"Map1": "Map2"
	}
}

var settings_map = {
	"time_between_waves": {
		"label": "Seconds Between Waves",
		"type": "slider",
		"min": 1,
		"max": 10
	},
	"starting_money": {
		"label": "Starting Money",
		"type": "slider",
		"min": 300,
		"max": 2000
	},
	"starting_base_health": {
		"label": "Starting Base Health",
		"type": "slider",
		"min": 1,
		"max": 200
	},
	"show_fps_monitor": {
		"label": "Show FPS",
		"type": "checkbox"
	}
}

var tower_data = {
	"GunT1": {
		"damage": 20,
		"rof": 0.3,
		"range": 300,
		"category": "Projectile",
		"cost": 200,
		"build_anywhere": false,
		"upgrades": ["GunT2"],
		"sound": true,
		"in_build_menu": true,
		"icon": "res://Assets/Towers/towerDefense_tile249.png"
	},
	"GunT2": {
		"damage": 0.5,
		"rof": 0.8,
		"range": 350,
		"category": "Custom",
		"cost": 400,
		"build_anywhere": false,
		"upgrade_cost": 200,
		"upgrades": [],
		"sound": true,
		"in_build_menu": false,
		"icon": "res://Assets/Towers/towerDefense_tile250.png"
	},
	"MissileT1": {
		"damage": 100,
		"rof": 3,
		"range": 550,
		"category": "Missile",
		"cost": 500,
		"build_anywhere": false,
		"upgrades": [],
		"sound": true,
		"in_build_menu": true,
		"icon": "res://Assets/Towers/towerDefense_tile251.png"
	},
	"AbilityBombT1": {
		"damage": 500,
		"rof": 5,
		"range": 300,
		"category": "Ability",
		"cost": 300,
		"build_anywhere": true,
		"upgrades": [],
		"sound": false,
		"in_build_menu": true,
		"icon": "res://Assets/Effects/explosion2.png"
	}
}

var editor_data_map = {
	"category": {
		"label": "Category",
		"type": "dropdown",
		"options": [
			"Projectile",
			"Custom",
			"Missile",
			"Ability"
		]
	},
	"damage": {
		"label": "Damage",
		"type": "slider",
		"min": 1,
		"max": 1000,
		"step": 0.5
	},
	"rof": {
		"label": "Rate of Fire",
		"type": "slider",
		"min": 0.1,
		"max": 5,
		"step": 0.1
	},
	"range": {
		"label": "Range",
		"type": "slider",
		"min": 20,
		"max": 1000,
		"step": 5
	},
	"build_anywhere": {
		"label": "Build Anywhere",
		"type": "checkbox"
	},
	"cost": {
		"label": "Cost",
		"type": "slider",
		"min": 5,
		"max": 1000,
		"step": 5
	},
	"sound": {
		"label": "Play Sound On Fire",
		"type": "checkbox"
	},
	"in_build_menu": {
		"label": "Show In Build Menu",
		"type": "checkbox"
	},
	"speed": {
		"label": "Speed",
		"type": "slider",
		"min": 20,
		"max": 300,
		"step": 5
	},
	"hp": {
		"label": "Hit Points",
		"type": "slider",
		"min": 20,
		"max": 300,
		"step": 5
	},
	"move_sound": {
		"label": "Move Sound",
		"type": "dropdown",
		"options": [
			"average",
			"fast",
			"slow"
		]
	},
	"sprite_path": {
		"label": "Sprite Path",
		"type": "text"
	}
}

var enemy_data = {
	"BlueTank": {
		"speed": 110,
		"hp": 200,
		"damage": 21,
		"sprite_path": "res://Assets/Enemies/tank_blue.png",
		"cost": 100,
		"move_sound": "average"
	},
	"RedTank": {
		"speed": 150,
		"hp": 50,
		"damage": 5,
		"sprite_path": "res://Assets/Enemies/tank_red.png",
		"cost": 50,
		"move_sound": "fast"
	},
	"BossTank": {
		"speed": 70,
		"hp": 500,
		"damage": 41,
		"sprite_path": "res://Assets/Enemies/tank_huge.png",
		"cost": 300,
		"move_sound": "slow"
	}
}

var waves = {
	"Map1": [
		{
			"enemies": [
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				}
			],
			"cost": 300,
			"boss_wave": false
		},
		{
			"custom_path": "PathTop",
			"enemies": [
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				}
			],
			"cost": 200,
			"boss_wave": false
		},
		{
			"enemies": [
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BossTank",
					"delay": 0.1
				}
			],
			"cost": 500,
			"boss_wave": true
		}
	],
	"Map2": [
		{
			"enemies": [
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BossTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BossTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BossTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BossTank",
					"delay": 0.7
				}
			],
			"cost": 300
		}
	],
	"MainMenuMap": [
		{
			"turrets": [
				{
					"type": "GunT1",
					"coords": {
						"x": 12,
						"y": 12
					},
					"delay": 0.5
				},
				{
					"type": "GunT1",
					"coords": {
						"x": 12,
						"y": 10
					},
					"delay": 0.5
				},
				{
					"type": "GunT1",
					"coords": {
						"x": 14,
						"y": 12
					},
					"delay": 0.5
				},
			],
			"enemies": [
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				}
			],
			"cost": 300,
			"boss_wave": false
		},
		{
			"turrets": [
				{
					"type": "GunT2",
					"coords": {
						"x": 12,
						"y": 10
					},
					"delay": 0.8,
					"upgrade": true
				},
				{
					"type": "MissileT1",
					"coords": {
						"x": 10,
						"y": 10
					},
					"delay": 1
				}
			],
			"enemies": [
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				}
			],
			"cost": 200,
			"boss_wave": false
		},
		{
			"turrets": [
				{
					"type": "GunT1",
					"coords": {
						"x": 12,
						"y": 6
					},
					"delay": 4,
					"upgrade": false
				},
				{
					"type": "AbilityBombT1",
					"coords": {
						"x": 13,
						"y": 12
					},
					"delay": 1
				}
			],
			"enemies": [
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "RedTank",
					"delay": 0.5
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 0.7
				},
				{
					"base": "Tank",
					"category": "BlueTank",
					"delay": 1
				},
				{
					"base": "Tank",
					"category": "BossTank",
					"delay": 0.1
				}
			],
			"cost": 500,
			"boss_wave": true
		}
	]
}

func update_setting(setting_key, value):
	settings[setting_key] = value
	emit_signal('setting_updated', setting_key, value)

## move to import?

func play_button_sound(node):
	node.stream = load("res://Assets/Audio/Sounds/click_003.ogg")
	node.stream.loop = false
	node.play()
	
func play_error_sound(node):
	node.stream = load("res://Assets/Audio/Sounds/error_007.ogg")
	node.stream.loop = false
	node.play()
	
func play_confirm_sound(node):
	node.stream = load("res://Assets/Audio/Sounds/confirmation_001.ogg")
	node.stream.loop = false
	node.play()

func play_upgrade_sound(node):
	node.stream = load("res://Assets/Audio/Sounds/confirmation_002.ogg")
	node.stream.loop = false
	node.play()
