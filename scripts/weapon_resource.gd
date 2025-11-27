extends Resource
class_name Weapons

@export var Name: StringName
@export_category("Animations")
@export var ActivateAnimName: String
@export var ShootAnimName: String
@export var ReloadAnimName: String
@export var DeactivateAnimName: String
@export_category("Data")
@export var CurrentAmmo: int
@export var StorageAmmo: int
@export var Magazine: int
@export var MaxAmmo: int
@export var AutoFire: bool
@export var Cooldown: float
@export_category("Model")
@export var Model: PackedScene
