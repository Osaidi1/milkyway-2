extends Node3D

@onready var animations: AnimationPlayer = $Animations

@export var weapon_resource: Array[Weapons] # Weapon Resources
@export var start_weapons: Array[Weapons] # Default Weapons

var current_weapon: Weapons # Weapon being Held
var weapon_stack := [] # Weapons that Player has
var weapon_indicator := 0 # Weapon Number that Player has
var weapon_next: Weapons # Weapon next in Hand
var weapon_list := {} # All weapons in game
var weapon_prevoius: Weapons # Stor old for Check
var is_changing_weapon := false # For Checking

func _ready() -> void:
	Initialize()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_up"):
		weapon_indicator = (weapon_indicator + 1) % weapon_stack.size()
		exit_weapon(weapon_stack[weapon_indicator])
	if event.is_action_pressed("weapon_down"):
		weapon_indicator = (weapon_indicator - 1 + weapon_stack.size()) % weapon_stack.size()
		exit_weapon(weapon_stack[weapon_indicator])

func Initialize() -> void:
	# List of All Weapons
	for weapon in weapon_resource:
		weapon_list[weapon.Name] = weapon
	
	# Start Weapons
	for i in start_weapons:
		weapon_stack.push_back(i)
	
	# Set and Enter Current Weapon
	current_weapon = start_weapons[0]
	enter_weapon()

func enter_weapon() -> void:
	animations.play(current_weapon.ActivateAnimName)

func exit_weapon(next_weapon: Weapons) -> void:
	if next_weapon.Name != current_weapon.Name:
		weapon_prevoius = current_weapon
		weapon_next = next_weapon
		is_changing_weapon = true
		if animations.get_current_animation() != current_weapon.DeactivateAnimName:
			animations.play(current_weapon.DeactivateAnimName)
		else:
			# Already deactivating, switch immediately
			change_weapon(weapon_next)
			is_changing_weapon = false

func shoot() -> void:
	pass

func change_weapon(weapon_name) -> void:
	if weapon_list.has(weapon_name):
		current_weapon = weapon_list[weapon_name]
		weapon_next = null
		enter_weapon()

func anim_finished(anim_name: StringName) -> void:
	if !is_changing_weapon: return
	if anim_name == weapon_prevoius.DeactivateAnimName:
		if weapon_next != null:
			change_weapon(weapon_next)
		is_changing_weapon = false
