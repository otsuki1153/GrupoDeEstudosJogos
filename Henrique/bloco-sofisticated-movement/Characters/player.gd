extends CharacterBody2D

#coyote time

#1. Crie uma variável para definir a duração da janela (ex: 0.15f ou 0.2 segundos) e um contador.
#2. Enquanto o jogador estiver no chão, mantenha o contador sempre igual ao tempo máximo permitido.
#3. Quando o jogador sair do chão (cair), faça o contador diminuir com o tempo (Time.deltaTime na Unity ou delta na Godot).
#4. Ao apertar o botão de pulo, verifique se o contador é maior que zero em vez de apenas checar se está tocando no chão.
#5. Assim que o pulo acontecer, zere o contador para evitar pulos extras.


# input buffering

#1. Crie uma variável para o tempo do buffer (ex: 0.15f segundos) e um contador.
#2. Toda vez que o jogador pressionar o botão de pulo, reinicie o contador do buffer com o valor máximo.
#3. Se o botão não for pressionado, faça o contador diminuir com o tempo (Time.deltaTime).
#4. No script de detecção de solo, se o jogador tocar no chão e o contador do buffer for maior que zero, execute o pulo imediatamente e zere o contador

# variable jump height (altura de pulo variável)

#1. Crie uma variável para o fator de corte (ex: 0.4 ou 0.5). Ela define quanto da subida sobra quando o jogador solta o botão.
#2. A cada frame, verifique se o botão de pulo foi solto naquele instante (procure a função irmã de is_action_just_pressed na classe Input).
#3. Se foi solto, verifique se o personagem ainda está subindo (lembre: na Godot o eixo Y aponta para baixo, então pense em qual sinal da velocity.y significa "subindo").
#4. Se estiver subindo, reduza a velocity.y multiplicando pelo fator de corte. Se estiver caindo, não faça nada.
#5. Deixe essa lógica em uma função própria (ex: handleJumpCut) e chame ela dentro do handleMovement, para não engordar o handleJump.
#6. Teste valores diferentes no fator de corte: perto de 1 quase não muda o pulo, perto de 0 vira um freio brusco no ar.


@export var maxSpeedWalk : float
@export var maxSpeedRun : float
@export var dashSpeed : float
@export var speed: float
@export var gravity:float
@export var jumpForce: float
@export var coyote_time : float = 0.15
@export var buff_time: float = 0.15
@export var jump_cut: float
var buff_counter: float 
var coyote_counter: float


func _physics_process(delta: float) -> void:
	handleMovement(delta)
	print(velocity.x)
	move_and_slide()
	

func handleHorizontalMove(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	var maxSpeed: float = 0
	
	if Input.is_action_just_pressed("shift"):
		velocity.x = direction * dashSpeed
	if Input.is_action_pressed("shift"):
		maxSpeed = maxSpeedRun
	else:
		maxSpeed = maxSpeedWalk
	velocity.x = move_toward(velocity.x, maxSpeed * direction, speed * delta)

func handleCoyoteCount(delta):
	coyote_counter -= delta

func handleGravity(delta):
		handleCoyoteCount(delta)
		velocity.y += gravity * delta
		

func jump():
	if coyote_counter > 0:
		velocity.y = -jumpForce
		coyote_counter = 0
		buff_counter = 0

func jumpCut():
	if velocity.y < 0:
		velocity.y *= jump_cut

func handleJump(delta):
	if Input.is_action_just_pressed("ui_accept"):
		buff_counter = buff_time
		jump()
	elif Input.is_action_just_released("ui_accept"):
		jumpCut()
	else:
		buff_counter -= delta

func groundLogic(delta):
	if not is_on_floor():
		handleGravity(delta)
	else:
		coyote_counter = coyote_time 
		velocity.y = 0
		if buff_counter > 0:
			jump()

func handleMovement(delta):
	groundLogic(delta)
	handleJump(delta)
	handleHorizontalMove(delta)
