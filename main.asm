.data
# ---------------------
# Registradores Salvos
# ---------------------
# s0 -> PLAYER_SPRITE
# s1 -> PLAYER_FRAME
# s2 -> ACTUAL MAP
# s3 ->

# --------------
# State Machine
# --------------
# 0 -> idle
# 1 -> attack
# 2 -> walking
# 3 -> down
STATE_MACHINE: 0
MAX_FRAMES_STATE: 8, 4, 16, 11

# ------------
# Player data
# ------------
PLAYER_XY: .word 144, 100
PLAYER_XY_ACL: 8,4

# 0 -> atual; 4 -> máximo
PLAYER_HP: 70,70

# 1 = left, 0 = right
PLAYER_DIR: .word 0
PLAYER_IDLE_FRAMES: 0


# player_attack duration
ATTACK_FRAMES: 0

# weapons
# 0 -> unnarmed

# ==========
# Inventory
# ==========
# in order: hand1 (0), hand2 (4), head (8), body (12), bonus 1 (16), 2 (20) and 3 (24)
INVENTORY: 0, 0, 0, 0, 0, 0, 0

# Jump data
Y_SPEED: .float 0.0
JUMP_FORCE: -8
GVT: .float 0.5
    # 0 means normal
    # 1 left and 2 right
    JUMP_DIR: .word 0,0 # second value -> jumping/not jumping

ENEMY_XY: .word 320, 120

CAMERA_XY: 0,0
# Input
INPUT: 0,0 # input and last input
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)
.eqv w 119
.eqv a 97
.eqv s 115
.eqv d 100
.eqv space 32
.eqv j_key 106

# BreakLine debug

NUM_LOOPS: 4
BL: .string "\n"
SPACE: .string " "
.text
# -----------------
# Game Start Setup
# -----------------
la s0 alucard_walk # carregar o valor de "sprite idle"
li s1 0
# --------------------------------------
# Dividir o game loop em menu e in-game
# --------------------------------------
#     la a0 prologue
# 	li a1 0
#     la a2 CAMERA_XY
#     lw a2, 0(a2)
#     li a3 960
# call RENDER
GAME_LOOP:
    # sleep?
    li a7 32
    li a0 10
    ecall    

    # zerar xlr8 horizontal
    la t0 PLAYER_XY_ACL
    sw zero 0(t0)
    
    # adicionar gravidade

    la t0 INPUT
    lw t1 0(t0)
    sw t1 4(t0) # Passa input anterior para last_input

    # decrementa num_loops
    la t0 NUM_LOOPS
    lw t1 0(t0)
    addi t1 t1 -1
    sw t1 0(t0)

    # implementando chamada de movimento
    INPUT_LOOP:
        li t0, MMIO_set # ready bit MMIO
        lb t1,(t0)
	bnez t1 SET_INPUT # wait time enquanto ready bit == 0

    # if theres no input: set actual input to zero and set last_input
    # timer to delimit input change -> only to jumping purposes
    la t0 NUM_LOOPS
    lw t1 0(t0)
    bgtz t1 END_CHECK_INPUT
    li t1 30 # time to wait for input change
    sw t1 0(t0)

    la t0 INPUT
    lw t1 0(t0)
    sw t1 4(t0) # Passa input anterior para last_input
    sw zero 0(t0) # zera input

    # antes de pular o input
    # resetar frame do personagem
    la t0 STATE_MACHINE
    lw t1 0(t0)
    bnez t1 SET_STATE_IDLE
        la s0 alucard_idle
    SET_STATE_IDLE:
        sw zero 0(t0)
    j END_CHECK_INPUT

    SET_INPUT:
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
    la t0 INPUT
    sw a0 0(t0) # Salva o valor de MMIO no endereço de INPUT
    # gerenciar input
    # j INPUT_MANAGER
    # AFTER_INPUT

    la t0 STATE_MACHINE
    li t1 3
    bne t0 t1 SKIP_STATE_DOWN_CHECK 
        call STATE_DOWN
    SKIP_STATE_DOWN_CHECK:

    j CHECK_INPUT
    END_CHECK_INPUT:

    # check if player is in the state "attack"
    la t0 STATE_MACHINE
    lw t0 0(t0)
    li t1 1
    beq t0 t1 STATE_ATTACK

    AFTER_STATE_ATTACK:

    # verificar colisao e movimentar personagem
    # o personagem vai sempre ser acelerado em sua x_speed e em sua y_speed
    j Y_MOVEMENT
    AFTER_MOVEMENT:

    #j ENEMY_PROCEDURE
    AFTER_ENEMY_PROCEDURE:

    # Idle Animation
    # la t0 STATE_MACHINE
    # lw t0 0(t0)
    # li t1 0
    # bne t0 t1 SKIP_ADD_FRAME

    # la t0 MAX_FRAMES_STATE
    # lw t0 0(t0)

    # bge s1 t0 RESET_ADD_FRAME

    # li a7 42
    # li a1 10
    # ecall
    # li t0 5
    # bge a0 t0 SKIP_ADD_FRAME
    # addi s1 s1 1
    # j SKIP_ADD_FRAME
    # RESET_ADD_FRAME:
    # li s1 0
    # SKIP_ADD_FRAME:

    li a7 42
    li a1 20
    ecall
    li t0 10
    bgt a0 t0 MOV_ENEMY_LEFT

    la t0 ENEMY_XY
    lw t1 0(t0)
    addi t1 t1 1
    sw t1 0(t0)
    j SKIP_ENEMY_MOV

    MOV_ENEMY_LEFT:
    la t0 ENEMY_XY
    lw t1 0(t0)
    addi t1 t1 1
    sw t1 0(t0)

    SKIP_ENEMY_MOV:

    j RENDER_PROCCESS

j GAME_LOOP

# O procedimento de renderização deve checar todos os objetos que podem aparecer na tela e printar de uma vez.
# começando sempre pelo mapa, depois pelos inimigos e por fim pelo personagem

# printar sobre o vetor camera -> printar o vetor

Y_MOVEMENT:

    # checar se ele não está colidindo com o chão
    la a0 PLAYER_XY
    la a1 entrance_col
    li a3 1
    call COLIDE_VERTICAL
    li t0 1

    bge a0 t0 SKIP_GRAVITY # se colidir -> set y_speed = 0 e sai do procedimento

    # checar se ao se mover ele colidirá com o chão
    # se sim, ele deve movimentar 1px por loop
    la t3 PLAYER_XY
    lw t3 4(t3)
    li t4 150
    la t2 Y_SPEED
    flw ft2 0(t2)
    fcvt.w.s t2 ft2 # convert y_speed to int
    add t3 t3 t2

    la a0 PLAYER_XY
    la a1 entrance_col
    mv a3 t2
    call COLIDE_VERTICAL
    li t4 1

    mv t3 a0

    bge t3 t4 PARTIAL_Y_MOVEMENT

    la t0 GVT
    flw ft0 0(t0)

    fadd.s ft0 ft2 ft0 # movement_y = actual_speed + (gravity_force)

    la t1 Y_SPEED
    fsw ft0 0(t1)

    la t3 PLAYER_XY
    lw t2 4(t3)
    flw ft1 0(t1)
    fcvt.w.s t0 ft1
    add t2 t2 t0
    sw t2 4(t3)
    j END_GRAVITY

# definir que o pulo acabou
SKIP_GRAVITY:
    la t0 JUMP_DIR
    li t1 0
    sw t1 4(t0)
    sw zero 0(t0)
    
    la t0 Y_SPEED
    sw zero 0(t0)

END_GRAVITY:
    # Check if char is jumping to left or right
    la t0 JUMP_DIR
    lw t1 4(t0)
    beqz t1 _ESCAPE

    lw t1 0(t0)
    li t2 1
    beq t1 t2 NEXT_D_ESCAPE
    la t0 CAMERA_XY
    lw a2 0(t0)
	addi a2 a2 2
    sw a2 0(t0)

    NEXT_D_ESCAPE:
    li t2 2
    beq t1 t2 _ESCAPE
    la t0 CAMERA_XY
    lw a2 0(t0)
	addi a2 a2 -2
    sw a2 0(t0)

    _ESCAPE:
    j AFTER_MOVEMENT

# se o prox y += y_speed for colidir, ele passa a descer 1px por loop
PARTIAL_Y_MOVEMENT:
    # call colide
    la a0 PLAYER_XY
    la a1 entrance_col
    li a3 0
    call COLIDE_VERTICAL
    li t2 1
    mv t0 a0

    bge t0 t2 END_GRAVITY

    la t3 PLAYER_XY
    lw t2 4(t3)
    li t1 1
    add t2 t2 t1
    sw t2 4(t3)
    j END_GRAVITY




j GAME_LOOP
.include "./render.s"
.include "./movimentacao.s"
.include "./state_machine.s"
.include "./input_handler.s"
.include "./enemy.s"