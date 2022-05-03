# state handler
STATE_FREE:
    # check state
    # execute state
    # if needed, reset state
    mv t0 s3 # carregar estado atual

    slli t1 t0 2 # transforma o valor de s3 em um ponteiro para o vetor
    la t2 MAX_FRAMES_STATE
    add t2 t2 t1
    lw t2 0(t2) # carregar o valor do max_frame do estado atual

    # STATE_DOWN
    li t3 3
    bne t3 s3 CHECK_STATE_IDLE
    bge s1 t2 RESET_FRAME_DOWN
    addi s1 s1 1
    j AFTER_STATE_FREE
    RESET_FRAME_DOWN:
        mv s1 t2
        j AFTER_STATE_FREE

    # slli t1 t0 2 # transforma o valor de s3 em um ponteiro para o vetor
    # la t2 MAX_FRAMES_STATE
    # add t2 t2 t1
    # lw t2 0(t2) # carregar o valor do max_frame do estado atual

    CHECK_STATE_IDLE:

    # checar qual é o estado e executar o procedimento correto
    li t3 0
    bne t3 s3 CHECK_STATE_ATTACK
    CHECK_STATE_ATTACK:
        slli t1 s3 2 # transforma o valor de s3 em um ponteiro para o vetor
        la t2 MAX_FRAMES_STATE
        add t2 t2 t1
        lw a2 0(t2) # carregar o valor do max_frame do estado atual

        li t3 1
        bne t3 s3 END_STATE_HANDLE
        call STATE_ATTACK
    END_STATE_HANDLE:

j AFTER_STATE_FREE

STATE_DOWN:
    mv t1 s3
    slli t1 t1 2 # multiplica por 4 o valor do state machine
    
    la t2 MAX_FRAMES_STATE
    add t2 t2 t1
    lw t2 0(t2) # carregar o valor do max_frame do estado atual

    bge s1 t2 END_STATE_DOWN
    addi s1 s1 1
    ret
    END_STATE_DOWN:
    ret

STATE_ATTACK:
    # checar arma 0(INVENTORY)
    # 0 -> unnarmed
    # 1 -> alucard sword
    # 2 -> short sword
    la t0 INVENTORY
    lw t0 0(t0)
    beqz t0 SET_SPRITE_UNNARMED

    SET_SPRITE_UNNARMED:
       la s0 alucard_punch

        # State attack
        # sprite handle
        # dentro do state será checada a colisão com os inimigos
        la s0 alucard_punch
        bge s1 a2 SKIP_ATK_FRAME
        addi s1 s1 1

    # Check if theres an enemy to hit
    # considering the hit box of the attk

    # temp -> utilizar a o sprite inteiro
    # em y: enemy_y and enemy_y + len(enemy_y) -> with cam y
    # em x: enemy_x and enemy_x + len(enemy_x) -> with map x
    la t0 ENEMY_XY
    lw t1 0(t0)
    lw t2 4(t0)

    # la t3 CAMERA_XY
    # lw t3 0(t3)
    # addi t3 t3 144 # adicionar no y da camera a posição inicial do personagem
    CHECK_HIT_X:
    mv t3 t1
    la t4 PLAYER_XY
    lw t4 0(t4)
    # checar se o inimigo está no mesmo x que o personagem
    la t5 CAMERA_XY
    lw t5 0(t5) # carregar o x da câmera em t5
    addi t5 t5 144
    ble t3 t5 LET_IT_ALIVE
    addi t5 t5 48
    bge t3 t5 LET_IT_ALIVE

    CHECK_HIT_Y:
    # se o inimigo estiver no mesmo x que o personagem, checar se ele stá no mesmo y
    mv t3 t2
    la t4 PLAYER_XY
    lw t5 4(t4)

    ble t3 t5 KILL_ENEMY
    addi t3 t2 48
    bge t3 t5 KILL_ENEMY
    j LET_IT_ALIVE
    KILL_ENEMY:
        la t0 ENEMY_IS_ALIVE
        lw t1 0(t0)
        beqz t1 LET_IT_ALIVE

        sw zero 0(t0)

    LET_IT_ALIVE:

    ret

    SKIP_ATK_FRAME:
        la s0 alucard_idle
        li s1 0 # reseta o valor do sprite
        li s3 0 # volta para o state idle
        #j AFTER_STATE_FREE
    ret

j GAME_LOOP