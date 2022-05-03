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