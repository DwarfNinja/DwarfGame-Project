extends StaticBody2D

onready var InteractArea = $InteractArea

func _ready():
	InteractArea.connect("body_entered", self, "_on_InteractArea_body_entered")

func _on_InteractArea_body_entered(body):
	if body.get_name() == "Player":
#		Events.emit_signal("entered_cave")
		Events.call_deferred('emit_signal', 'entered_cave')
