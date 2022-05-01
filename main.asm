.data
# Player data
PLAYER_XY: .word 144, 100
PLAYER_XY_ACL: 8,4

# 1 = left, 0 = right
PLAYER_DIR: .word 0

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

# BreakLine debug

NUM_LOOPS: 4
BL: .string "\n"
SPACE: .string " "
.text
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
    j END_CHECK_INPUT

    SET_INPUT:
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
    la t0 INPUT
    sw a0 0(t0) # Salva o valor de MMIO no endereço de INPUT
    # gerenciar input
    # j INPUT_MANAGER
    # AFTER_INPUT

    j CHECK_INPUT
    END_CHECK_INPUT:

    # verificar colisao e movimentar personagem
    # o personagem vai sempre ser acelerado em sua x_speed e em sua y_speed
    j Y_MOVEMENT
    AFTER_MOVEMENT:

    #j ENEMY_PROCEDURE
    AFTER_ENEMY_PROCEDURE:

    j RENDER_PROCCESS

j GAME_LOOP

# WIP - ao checar o input, deveria ser preparado tudo para posteriormente chamar a colisão + o movimento em x e em y
CHECK_INPUT:
    la a0 INPUT
    lw t0, 0(a0)
    li t1 space
    beq t0 t1 JUMP_KEY_PRESSED
    li t1 w
    bne t0 t1 NEXT_A
    
    JUMP_KEY_PRESSED:

    # check if char's on the ground
    la t4 PLAYER_XY
    lw t5 4(t4)
    li t4 152

    la a0 PLAYER_XY
    la a1 entrance_col
    li a3 1
    call COLIDE_VERTICAL
    li t4 1
    mv t5 a0

    bne t5 t4 END_CHECK_INPUT

    la t0 JUMP_DIR
    li t1 1
    sw t1 4(t0) # set jumping = true

    # define jump property
    # a jump can be null, left or right. It's defined when the player presses the jump key
    # and only changes when it touchs the ground
    la t0 JUMP_DIR # reset jump kind
    sw zero 0(t0)

    la t0 INPUT
    lw t1 4(t0)
    li t2 a
    bne t1 t2 CHECK_RIGHT_JUMP
    la t0 JUMP_DIR
    li t2 1
    sw t2 0(t0) # if last_input == a, JUMP_DIR = 1
    CHECK_RIGHT_JUMP:
    la t0 INPUT
    lw t1 4(t0)
    li t2 d
    bne t1 t2 NORMAL_JUMP
    la t0 JUMP_DIR
    li t2 2
    sw t2 0(t0) # if last_input == d, JUMP_DIR = 2

NORMAL_JUMP:
    la t4 PLAYER_XY
    lw t5 4(t4)
    addi t5 t5 -4
    sw t5 4(t4)

    # carrega o valor de jump force
    la t0 JUMP_FORCE
    lw t0, 0(t0)
    fcvt.s.w ft0 t0 # convert jump_force to float
    fmv.s.x ft0 t0 # convert jump_force to x_speed

    # carrega o valor de y_speed
    la t1 Y_SPEED
    flw ft1 0(t1)

    # adiciona o valor de jump force em y_speed
    fadd.s ft1 ft1 ft0
    fsw ft1 0(t1)

    NEXT_A:

    # check if char's on the ground
    la t4 PLAYER_XY
    lw t5 4(t4)
    li t4 152

    la a0 PLAYER_XY
    la a1 entrance_col
    li a3 1
    call COLIDE_VERTICAL
    li t4 1
    mv t5 a0

    bne t5 t4 END_CHECK_INPUT

    la a0 INPUT
    lw t0, 0(a0)
    li t1 a
    bne t0, t1, NEXT_D

    # checar se colide horizontal esquerda <-
    # checar se o player colide horizontalmente
    la a0 PLAYER_XY
    la a1 entrance_col
    la a2 CAMERA_XY
    li a3 -1
    call COLIDE_HORIZONTAL_LEFT
    li t4 1
    mv t5 a0
    # se colidir -> checar colisão do movimento parcial
    bge t5 t4 SKIP_INPUT

    la a0 PLAYER_XY
    la a1 entrance_col
    la a2 CAMERA_XY
    li a3 -16
    call COLIDE_HORIZONTAL_LEFT
    li t4 1
    mv t5 a0

    # se colidir no movimento parcial -> aplicar movimento parcial
    # caso contrário: aplicar movimento normal
    beqz t5 PARTIAL_XL_MOVEMENT

    la t0 CAMERA_XY
    lw a2 0(t0)
	addi a2 a2 -1
    sw a2 0(t0)

    j AFTER_HL_MOVEMENT

    PARTIAL_XL_MOVEMENT:
        la t0 CAMERA_XY
        lw a2 0(t0)
        addi a2 a2 -16
        sw a2 0(t0)


    AFTER_HL_MOVEMENT:

    NEXT_D:

    # check if char's on the ground
    la t4 PLAYER_XY
    lw t5 4(t4)
    li t4 152

    la a0 PLAYER_XY
    la a1 entrance_col
    li a3 1
    call COLIDE_VERTICAL
    li t4 1
    mv t5 a0

    bne t5 t4 END_CHECK_INPUT

    la a0 INPUT
    lw t0, 0(a0)
    li t1 d
    bne t0, t1, SKIP_INPUT

    # checar se o player colide horizontalmente
    la a0 PLAYER_XY
    la a1 entrance_col
    la a2 CAMERA_XY
    li a3 1
    call COLIDE_HORIZONTAL_RIGHT
    li t4 1
    mv t5 a0
    # se colidir -> checar colisão do movimento parcial
    bge t5 t4 SKIP_INPUT

    la a0 PLAYER_XY
    la a1 entrance_col
    la a2 CAMERA_XY
    li a3 16
    call COLIDE_HORIZONTAL_RIGHT
    li t4 1
    mv t5 a0

    # se colidir no movimento parcial -> aplicar movimento parcial
    # caso contrário: aplicar movimento normal
    beqz t5 PARTIAL_XR_MOVEMENT

    la t0 CAMERA_XY
    lw a2 0(t0)
	addi a2 a2 1
    sw a2 0(t0)

    j AFTER_HR_MOVEMENT

    PARTIAL_XR_MOVEMENT:
        la t0 CAMERA_XY
        lw a2 0(t0)
        addi a2 a2 16
        sw a2 0(t0)


    AFTER_HR_MOVEMENT:

    SKIP_INPUT:
    j  END_CHECK_INPUT
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


ENEMY_PROCEDURE:
# Create the logic to find if enemy's on the screen (and how many pixels of it's on the screen)
# and print it
CHECK_IF_ENEMY_ON_SCREEN:
    # conferir se x do inimigo está entre x_camera e x_camera-320
    la t0 ENEMY_XY
    lw t1 0(t0)
    lw t2 4(t0)
    
    la t3 CAMERA_XY
    lw t3 0(t3)
    blt t1 t3 SKIP_ENEMY_RENDER
    addi t3 t3 320
    bgt t1 t3 SKIP_ENEMY_RENDER

    # converter a posição do inimigo para uma posição na tela e renderizar
    la a0 teste_enemy
    la t0 ENEMY_XY
    lw t1 0(t0)
    lw t2 4(t0)
    li t3 320
    mul t3 t3 t2
    add a1 t3 t1
    li a2 0
    li a3 24
    la a4 camera
    addi a4 a4 8
    call RENDER_ON_CAMERA
    SKIP_ENEMY_RENDER:
    j END_CHECK_IF_ENEMY_ON_SCREEN
    j AFTER_ENEMY_PROCEDURE

RENDER_PROCCESS:
    # renderizar mapa
    
    la a0 entrance_col
	li a1 0
    la a2 CAMERA_XY
    lw a2, 0(a2)
    li a3 960
    la a4 camera
    addi a4 a4 8
    call RENDER_ON_CAMERA

    # ...
    # Objects
    # ...


    # Player
    la a0 RichterBelmont
    la t0 PLAYER_XY
    lw t1 0(t0)
    lw t2 4(t0)
    li t3 320
    mul t3 t3 t2
    add a1 t3 t1
    li a2 0
    li a3 24
    la a4 camera
    addi a4 a4 8
    call RENDER_ON_CAMERA

    j CHECK_IF_ENEMY_ON_SCREEN
    END_CHECK_IF_ENEMY_ON_SCREEN:

    la a0 camera
	li a1 0
    li a2 0
    li a3 320
    call RENDER

j GAME_LOOP
.include "./render.s"
.include "./movimentacao.s"
