# WIP - ao checar o input, deveria ser preparado tudo para posteriormente chamar a colisão + o movimento em x e em y
CHECK_INPUT:
    # check if !STATE_ATTACK
    mv t0 s3
    li t1 1

    beq t1 t0 SKIP_INPUT

    # check if input 
    la a0 INPUT
    lw t0 0(a0)
    li t1 j_key
    bne t0 t1 JUMP_INPUT
    # attack logic
    # 1 - checar se qual arma está equipada -> caso não tenha nenhuma arma usar ataque desarmado
    # 2 - trocar o sprite para o da arma e rodar a animação
    # 3 - procurar por inimigos no alcance da arma para hitar
    
    la s0 alucard_punch
    li s1 -1 # reset attack frames
    li s3 1 # state attack
    
    #j STATE_ATTACK

    JUMP_INPUT:
    la a0 INPUT
    lw t0, 0(a0)
    li t1 space
    beq t0 t1 JUMP_KEY_PRESSED
    li t1 k
    beq t0 t1 JUMP_KEY_PRESSED
    li t1 w
    bne t0 t1 NEXT_A
    
    JUMP_KEY_PRESSED:

    # check if char's on the ground
    la t4 PLAYER_XY
    lw t5 4(t4)
    li t4 152

    la a0 PLAYER_XY
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col

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
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col

    li a3 1
    call COLIDE_VERTICAL
    li t4 1
    mv t5 a0

    bne t5 t4 END_CHECK_INPUT

    la a0 INPUT
    lw t0, 0(a0)
    li t1 a
    bne t0, t1, NEXT_D

    la t0 PLAYER_DIR
    li t1 1
    sw t1 0(t0)

    # checar se colide horizontal esquerda <-
    # checar se o player colide horizontalmente
    la a0 PLAYER_XY
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col

    la a2 CAMERA_XY
    li a3 -1
    call COLIDE_HORIZONTAL_LEFT
    li t4 1
    mv t5 a0
    # se colidir -> checar colisão do movimento parcial
    bge t5 t4 SKIP_INPUT

    # aumentar frames do sprite
    la s0 alucard_walk # definir sprite como player_idle
    li t0 16
    bge s1 t0 RESET_FRAME_WALK_LEFT
        addi s1 s1 1
        j SKIP_FRAME_RESET_WALK_LEFT

    RESET_FRAME_WALK_LEFT:
        li s1 0

    SKIP_FRAME_RESET_WALK_LEFT:

    la a0 PLAYER_XY
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col

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
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col

    li a3 1
    call COLIDE_VERTICAL
    li t4 1
    mv t5 a0

    bne t5 t4 END_CHECK_INPUT

    la a0 INPUT
    lw t0, 0(a0)
    li t1 d
    bne t0, t1, NEXT_S

    la t0 PLAYER_DIR
    sw zero 0(t0)

    # checar se o player colide horizontalmente
    la a0 PLAYER_XY
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col

    la a2 CAMERA_XY
    li a3 1
    call COLIDE_HORIZONTAL_RIGHT
    li t4 1
    mv t5 a0
    # se colidir -> checar colisão do movimento parcial
    bge t5 t4 SKIP_INPUT

    # aumentar frames do sprite
    la s0 alucard_walk # definir sprite como player_idle
    li t0 16
    bge s1 t0 RESET_FRAME_WALK_DIR
        addi s1 s1 1
        j SKIP_FRAME_RESET_WALK_DIR

    RESET_FRAME_WALK_DIR:
        li s1 0

    SKIP_FRAME_RESET_WALK_DIR:

    la a0 PLAYER_XY
    # la a1 entrance_col
    call MAP_COL_SELECTOR # returns in a1 map_col
    
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

    NEXT_S:
    la a0 INPUT
    lw t0, 0(a0)
    li t1 s
    bne t0, t1, SKIP_INPUT

    # procedimento de abaixar
    la s0 alucard_down
    li t0 11
    #bge s1 t0 SKIP_INPUT
    li s1 -1
    li s3 3

    #call STATE_DOWN

    SKIP_INPUT:
    j  END_CHECK_INPUT

j GAME_LOOP