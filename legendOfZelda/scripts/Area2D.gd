extends Area2D


@export var cam: PackedScene
cam = $Camera2D

func _on_body_entered(body):
	if body.name == "Player" :
		cam = $CaveCam
