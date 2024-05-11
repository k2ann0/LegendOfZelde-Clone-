extends CharacterBody2D

## NOTLAR ##
	## operatör değişken isimlendirme
	## $ -> önden arkaya çağırma
	## @export -> karaktere özellik ekleme
	## @onready -> ön taraftaki node'u arkaya çağırma



@export var speed = 50
@export var sword: PackedScene
@onready var animationPlayer = $AnimationPlayer

var dmg = 25
var amount = 3
var currentDir = "none"
var attackDetector = false
var enemyInAttackRange = false
var enemyAttackCooldown = true
var health = 1000
var playerAlive = true

func inputHandle () :
	var moveDirection = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = moveDirection * speed

func updateAnimation() :
	if attackDetector == false :
		if velocity.length() == 0 :
			#animationPlayer.play("idle")
			animationPlayer.stop()
		else :
			if attackDetector == false :
				var dir = "Up"
				$HandPos.rotation_degrees = 90 
				if velocity.x > 0 : 
					dir = "Right"
					$HandPos.rotation_degrees = 0 
				elif velocity.x < 0 : 
					dir = "Left"
					$HandPos.rotation_degrees = 180
				elif velocity.y < 0 : 
					dir = "Down"
					$HandPos.rotation_degrees = -90
				animationPlayer.play("walk" + dir)

func shoot():
	var s = sword.instantiate()
	add_child(s)
	s.setDamage(dmg)
	s.transform = $HandPos.transform
	s.position = $HandPos.global_position
	$swordAudio.play()

func _process(delta):
	if Input.is_action_just_pressed("sword"):
		if amount > 0 :
			amount = amount - 1
			shoot()



func attack() :
	if Input.is_action_just_pressed("attack") :
		Global.playerCurrentAttack = true
		attackDetector = true
		var dir = currentDir
		if velocity.x > 0 : 
			dir = "Right"
			$dealAttackTimer.start()
			animationPlayer.play("attack" + dir)
		elif velocity.x < 0 : 
			dir = "Left"
			$dealAttackTimer.start()
			animationPlayer.play("attack" + dir)
		elif velocity.y < 0 : 
			dir = "Up"
			$dealAttackTimer.start()
			animationPlayer.play("attack" + dir)
		elif velocity.y > 0 : 
			dir = "Down"
			$dealAttackTimer.start()
			animationPlayer.play("attack" + dir)

func player() :
	pass

func enemyAttack() : 
	if enemyInAttackRange and enemyAttackCooldown==true : 
		health = health - 15
		enemyAttackCooldown = false
		$attackCoolDown.start()
		print("Player Health : " , health)

func swordReload():
	if amount == 3 :
		return false
	else :
		amount += 1
		return true

func healed() : 
	if $HUD/hpBar.value == 3 :
		return false
	else :
		$HUD/hpBar.value += 0.5
		$"../healAudio".play()
		return true 

func _on_hit_box_body_entered(body):
	if body.has_method("enemy") :
		enemyInAttackRange = true

func _on_hit_box_body_exited(body):
	if body.has_method("enemy") : 
		enemyInAttackRange = false

func _on_attack_cool_down_timeout():
	enemyAttackCooldown = true
	#print("attack cool down")

func _on_deal_attack_timer_timeout():
	$dealAttackTimer.stop()
	Global.playerCurrentAttack = false
	attackDetector = false
	#print("deal attack timer")
	
func hurt() : 
	$HUD/hpBar.value -= 0.5
	$"../damageAudio".play()
	if $HUD/hpBar.value == 0 :
		get_tree().reload_current_scene()

func _physics_process(delta):
	inputHandle()
	updateAnimation()
	move_and_slide()
	attack()
	enemyAttack()
	if health <= 0 :
		playerAlive = false 
		health = 0
		self.queue_free()






