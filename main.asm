.data
# ---------------------
# Registradores Salvos
# ---------------------
# s0 -> PLAYER_SPRITE
# s1 -> PLAYER_FRAME
# s2 -> ACTUAL MAP
# s3 -> STATE
# s4 -> dano da arma atual

# --------------
# State Machine
# --------------
# 0 -> idle
# 1 -> attack
# 2 -> walking
# 3 -> down
# 4 -> sword
# 5 -> power
# STATE_MACHINE: 0
MAX_FRAMES_STATE: 8, 4, 16, 10, 8, 4
# 8, 4, 16, 10

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

# exist, x (camera), y (player)
POWER: 0, 0, 0, 0

# player_attack duration
ATTACK_FRAMES: 0

# weapons
# 0 -> unnarmed
# 1 -> alucard_sword
DAMAGE: -6, -20
WEAPON_RANGE: 16, 64
# ==========
# Inventory
# ==========
# in order: hand1 (0), hand2 (4), head (8), body (12), bonus 1 (16), 2 (20) and 3 (24)
INVENTORY: 1, 0, 0, 0, 0, 0, 0

# Jump data
Y_SPEED: .float 0.0
JUMP_FORCE: -8
GVT: .float 0.5
    # 0 means normal
    # 1 left and 2 right
    JUMP_DIR: .word 0,0 # second value -> jumping/not jumping

CAMERA_XY: 0,0

# Maps
ACTUAL_MAP: 0, 3 # 4(ACUTAL_MAP) -> total num maps
MAPS: entrance, entrance_pedra_top
MAPS_COL: entrance_col, entrance_pedra_top_col

# ------------------
# Mapa 0 - Entrance
# ------------------
ENEMY_XY0: 320, 120, 320 140, 640, 153
ENEMY_IS_ALIVE0: 1,1,1,1,1,1,1,1,1
ENEMY_HP0: 10, 2, 1, 20, 10, 7, 6
ENEMY_TYPE0: 0,0,0,0,0,0,0,0,0,0,0,0
NUM_ENEMIES0: 3
ENEMY_HURT0: 0,0,0,0,0,0,0,0,0,0,0,0
ENEMY_FRAME0: 0,4,0,4,0,4,0,4,0,4,0,4,0,4,0,4,0,4
ENEMY_DAMAGE0: 0,0,0,0,0,0,0,0,0,0,0,0

ENEMY_XY: 320, 120, 320 140 , 640, 153
ENEMY_IS_ALIVE: 1,1,1,1,1,1,1,1,1
ENEMY_HP: 10, 2, 1, 20, 10, 7, 6
NUM_ENEMIES: 4
ENEMY_TYPE: 0,0,0,0,0,0,0,0,0,0,0,0
ENEMY_HURT: 0,0,0,0,0,0,0,0,0,0,0,0
ENEMY_FRAME: 0,4,0,4,0,4,0,4,0,4,0,4,0,4,0,4,0,4
ENEMY_DAMAGE: 0,0,0,0,0,0,0,0,0,0,0,0
# Input
INPUT: 0,0 # input and last input
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)
.eqv w 119
.eqv a 97
.eqv s 115
.eqv d 100
.eqv space 32
.eqv k 107
.eqv j_key 106
.eqv r 114
.eqv l 108

SCENE_LOOP: 0

TAMANHO: 44
NOTAS: .word 77,130,76,130,73,130,72,130,73,130,72,130,71,130,73,130,72,391,67,391,67,130,72,130,77,130,76,130,73,130,72,130,71,130,69,130,79,130,77,130,76,261,77,261,79,261,79,130,82,130,83,130,82,130,79,130,77,130,79,130,77,130,79,130,82,130,79,391,72,391,72,130,74,130,76,391,77,391,81,261,79,261,74,261,73,261,67,261

# BreakLine debug

NUM_LOOPS: 4
BL: .string "\n"
SPACE: .string " "
.text
# Victory music
	li a2 7
	li a3 60
	li t0 10
	li t1 0
	la t2 NOTAS
	li a7 33
	LOOP_MUSICA:
	lw a0 0(t2)
	lw a1 4(t2)
	addi t2 t2 8
	addi t1 t1 1
	ecall
	blt t1 t0 LOOP_MUSICA

# -----------------
# Game Start Setup
# -----------------

# ---------
# HISTÓRIA
# ---------
# RENDER BELMONT COM O LAMAR

li s7 3
li s6 0
RENDER_SCENE_LOOP:
la a0 prologue
lw t0 0(a0)
li a1 0
li a2 310
li a3 960
la a4 camera
addi a4 a4 8
call RENDER_ON_CAMERA_INVERT

la t2 prologue
lw t2 0(t2)
la a0 RichterBelmont
li t0 50
mul t0 t0 t2
addi a1 t0 240

li a2 0
li a3 24
la a4 camera
addi a4 a4 8
call RENDER_ON_CAMERA_INVERT

la a0 npc
la t2 prologue
lw t2 0(t2)
li t0 43
mul t0 t0 t2
addi a1 t0 150
li a2 0
li a3 48
la a4 camera
addi a4 a4 8
call RENDER_ON_CAMERA_INVERT


beqz s6 DIALOGO1
li t0 1
beq t0 s6 DIALOGO2
li t0 2
beq t0 s6 DIALOGO3

DIALOGO3:
la a0 dialogo3
j RENDER_SCENE

DIALOGO2:
la a0 dialogo2
j RENDER_SCENE

DIALOGO1:
la a0 dialogo1
j RENDER_SCENE

RENDER_SCENE:
la t2 prologue
lw t2 0(t2)
li t0 -10
mul t0 t0 t2
addi a1 t0 10
li a2 0
li a3 320
la a4 camera
addi a4 a4 8
call RENDER_ON_CAMERA

# RENDER CAM IMG
la a0 camera
li a1 0
li a2 0
li a3 320
call RENDER

li a7 32
li a0 2000
ecall

INPUT_LOOP_SCENE:
    li t0, MMIO_set # ready bit MMIO
    lb t1,(t0)
bnez t1 INPUT_LOOP_SCENE # wait time enquanto ready bit == 0

li s7 3

la t0 SCENE_LOOP
lw s6 0(t0)
addi s6 s6 1
sw s6 0(t0)
bgt s6 s7 GAME_FIRST_INIT
j RENDER_SCENE_LOOP

GAME_FIRST_INIT: # and reset
la s0 alucard_idle # carregar o valor de "sprite idle"
li s1 0
li s3 0
li s4 -6
li s5 -30

call START_GAME

# --------------------------------------
# Dividir o game loop em menu e in-game
# --------------------------------------
#     la a0 prologue
# 	  li a1 0
#     la a2 CAMERA_XY
#     lw a2, 0(a2)
#     li a3 960
# call RENDER
GAME_LOOP:
    la t0 PLAYER_HP
    lw t0 0(t0)
    blez t0 _GAME_OVER
    j KEEP_MOVING
    _GAME_OVER:
        j GAME_OVER

    KEEP_MOVING:
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
    mv t1 s3
    bnez t1 SET_STATE_IDLE
        la s0 alucard_idle
    SET_STATE_IDLE:
        li s3 0
        #sw zero 0(t0)
    j END_CHECK_INPUT

    SET_INPUT:
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
    la t0 INPUT
    sw a0 0(t0) # Salva o valor de MMIO no endereço de INPUT
    # gerenciar input
    # j INPUT_MANAGER
    # AFTER_INPUT

    mv t0 s3
    li t1 3
    bne t0 t1 SKIP_STATE_DOWN_CHECK 
        #call STATE_DOWN
    SKIP_STATE_DOWN_CHECK:

    j CHECK_INPUT
    END_CHECK_INPUT:

    # check if player is in the state "attack"
    mv t0 s3
    li t1 1
    #beq t0 t1 STATE_ATTACK

    AFTER_STATE_ATTACK:

    # Executar máquina de estados
    j STATE_FREE
    AFTER_STATE_FREE:

    # verificar colisao e movimentar personagem
    # o personagem vai sempre ser acelerado em sua x_speed e em sua y_speed
    j Y_MOVEMENT
    AFTER_MOVEMENT:

    #j ENEMY_PROCEDURE
    AFTER_ENEMY_PROCEDURE:


    # check if it should destroy your poower
    STOP_YOURSELF:
        la t0 POWER
        lw t1 0(t0)
        beqz t1 WORLD_PEACE
            lw t2 4(t0)
            la t3 CAMERA_XY
            lw t3 0(t3)
            
            ble t2 t3 GIVEUP_YOUR_POWER

            addi t2 t2 16
            addi t3 t3 290
            bgt t2 t3 GIVEUP_YOUR_POWER

            j WORLD_PEACE

        GIVEUP_YOUR_POWER:
            sw zero 0(t0) # poder não existe

    WORLD_PEACE:

    la t0 POWER
    lw t0 0(t0)
    beqz t0 AFTER_POWER
    j POWER_PROC
    AFTER_POWER:

    # Idle Animation
    # mv t0 s3
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
    AFTER_RENDER_PROCESS:

    j CHECK_IF_NEXT_MAP
    AFTER_CHECK_IF_NEXT_MAP:

j GAME_LOOP

GAME_OVER:
    li a7 10
    ecall

.include "./render.s"
.include "./movimentacao.s"
.include "./state_machine.s"
.include "./input_handler.s"
.include "./enemy.s"
.include "./gravity.s"
.include "./map_handler.s"
.include "./power.s"
.include "./sons_ataques.s"