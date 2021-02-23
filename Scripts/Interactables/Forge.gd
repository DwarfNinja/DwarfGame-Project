extends Interactable_Object

onready var ForgeTimer = $ForgeTimer

var iron = preload("res://Resources/Resources/Iron.tres")
var forge_time = 5
var iron_in_forge = 0
var set_iron_amount = null

var iron_1 = preload("res://Sprites/Interactables/Craftables/Forge/Forge Iron1.png")
var iron_2 = preload("res://Sprites/Interactables/Craftables/Forge/Forge Iron2.png")

func _ready():
	# Connect signals
	ForgeTimer.connect("timeout", self, "_on_ForgeTimer_timeout")
	Events.connect("iron_amount_set", self, "_on_iron_amount_set")

func _process(_delta):
	if can_interact == true:
		if ForgeTimer.is_stopped() and iron_in_forge == 0:
			InteractableSprite.material.set_shader_param("outline_color", Color(240,240,240,255)) #Visible
		elif iron_in_forge > 0:
			InteractableSprite.material.set_shader_param("outline_color", Color(240,240,240,0)) #Visible
			$Iron.material.set_shader_param("outline_color", Color(240,240,240,255)) 
		else:
			InteractableSprite.material.set_shader_param("outline_color", Color(240,240,240,0))
			$Iron.material.set_shader_param("outline_color", Color(240,240,240,0))
			
	update_iron_sprite()

func interact():
	if iron_in_forge == 0:
		Events.emit_signal("open_forge", self)
	elif iron_in_forge > 0:
		if HUD.InventoryBar.can_fit_in_inventory(iron):
			Events.emit_signal("item_picked_up", iron)
			iron_in_forge -= 1
	else:
		print("Forge is still smelting!")
				
func _on_iron_amount_set(current_opened_forge, slider_iron_amount):
	if self == current_opened_forge:
		ForgeTimer.wait_time = forge_time * slider_iron_amount
		ForgeTimer.start()
		set_iron_amount = slider_iron_amount

func _on_ForgeTimer_timeout():
	if iron_in_forge < 20:
		iron_in_forge += 2 * set_iron_amount

func update_iron_sprite():
	if iron_in_forge > 0:
		if iron_in_forge <= 5:
			$Iron.texture = iron_1
		elif iron_in_forge > 5:
			$Iron.texture = iron_2
	else:
		$Iron.texture = null

