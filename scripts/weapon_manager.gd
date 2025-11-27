extends Node3D

@onready var animations: AnimationPlayer = $Animations

@export var weapon_resource: Array[Weapons] # Weapon Resources
@export var start_weapons: Array[Weapons] # Default Weapons

var current_weapon = null # Weapon being Held
var weapon_stack := [] # Weapons that Player has
var weapon_indicator := 0 # Weapon Number that Player has
var weapon_next: String # Weapon next in Hand
var weapon_list := {} # All weapons in game

func _ready() -> void:
	Initialize()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon 1") and current_weapon != weapon_stack[0]:
		exit_weapon()
		change_weapon()

func Initialize() -> void:
	# List of All Weapons
	for weapon in weapon_resource:
		weapon_list[weapon.Weapons_Name] = weapon
	
	# Start Weapons
	for i in start_weapons:
		weapon_stack.push_back(i)
	
	# Set and Enter Current Weapon
	current_weapon = start_weapons[0]
	enter_weapon()

func enter_weapon() -> void:
	weapon_indicator = weapon_stack[0]
	animations.queue(current_weapon.ActivateAnimName)

func exit_weapon() -> void:
	animations.queue(current_weapon.DeactivateAnimName)

func shoot() -> void:
	pass

func change_weapon() -> void:
	pass
