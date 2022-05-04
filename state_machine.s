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
    li t1 9
    blt t0 t1 SET_SPRITE_SWORD

    SET_SPRITE_UNNARMED:
        # State attack
        # sprite handle
        # dentro do state será checada a colisão com os inimigos
        la s0 alucard_punch#alucard_punch
        bge s1 a2 SKIP_ATK_FRAME
        addi s1 s1 1
    j HIT_ENEMIES

    SET_SPRITE_SWORD:
        la s0 alucard_hit_weapon#alucard_punch
        la a2 MAX_FRAMES_STATE
        addi a2 a2 16
        lw a2 0(a2)
        bge s1 a2 SKIP_ATK_FRAME
        addi s1 s1 1 
    j HIT_ENEMIES

    HIT_ENEMIES:
    # HIT LOOP
    li t6 0 # contador de inimigos
    la a3 NUM_ENEMIES
    lw a3 0(a3)

    ENEMY_HIT_LOOP:
    # Check if theres an enemy to hit
    # considering the hit box of the attk

    # a hitbox (rectangle) can be described with two points:
    # top left and bottom right
    # so it's needed to check if the rectagle
    # l1/r1 overlaps l2/r2

    # temp -> utilizar a o sprite inteiro
    # em y: enemy_y and enemy_y + len(enemy_y) -> with cam y
    # em x: enemy_x and enemy_x + len(enemy_x) -> with map x
    la t0 ENEMY_XY
    # deslocar ponteiro de inimigo
    slli t1 t6 3
    add t0 t0 t1

    lw t1 0(t0) # l1.x
    lw t2 4(t0) # l1.y

    # la t3 CAMERA_XY
    # lw t3 0(t3)
    # addi t3 t3 144 # adicionar no y da camera a posição inicial do personagem
    # adicionar em x o valor de len(weapon_x)
    CHECK_HIT_X:
    la t2 INVENTORY
    lw t2 0(t2)
    beqz t2 SKIP_ADD_WEAPON_RANGE

    la t0 WEAPON_RANGE
    lw t0 4(t0)
    slli t2 t2 2
    add t0 t0 t2
    lw t2 0(t0)

    la t0 PLAYER_DIR
    lw t0 0(t0)
    bnez t0 CHECK_HIT_LEFT_X

    SKIP_ADD_WEAPON_RANGE:
        mv t3 t1
        la t4 PLAYER_XY
        lw t4 0(t4) # x do player
        # checar se o inimigo está no mesmo x que o personagem
        la t5 CAMERA_XY
        lw t5 0(t5) # carregar o x da câmera em t5
        addi t5 t5 144
        addi t5 t5 48
        add t5 t5 t2
        bge t3 t5 LET_IT_ALIVE
        addi t5 t5 -48
        sub t5 t5 t2
        addi t3 t3 24
        ble t3 t5 LET_IT_ALIVE

    j CHECK_HIT_Y

    CHECK_HIT_LEFT_X:
        sub t2 zero t2 # deixa o range negativo
        mv t3 t1
        la t4 PLAYER_XY
        lw t4 0(t4) # x do player
        # checar se o inimigo está no mesmo x que o personagem
        la t5 CAMERA_XY
        lw t5 0(t5) # carregar o x da câmera em t5
        addi t5 t5 144
        addi t5 t5 -48
        add t5 t5 t2
        bge t5 t3 LET_IT_ALIVE
        addi t5 t5 48
        sub t5 t5 t2
        sub t5 t5 t2
        addi t3 t3 24
        ble t5 t3 LET_IT_ALIVE

    CHECK_HIT_Y:
    la t0 ENEMY_XY
    # deslocar ponteiro de inimigo
    slli t1 t6 3
    add t0 t0 t1

    # se o inimigo estiver no mesmo x que o personagem, checar se ele stá no mesmo y
    lw t2 4(t0) # l1.y
    mv t3 t2
    la t4 PLAYER_XY
    lw t5 4(t4)

    addi t5 t5 48
    ble t5 t3 KILL_ENEMY
    addi t5 t5 -48
    addi t3 t2 48
    ble t5 t3 KILL_ENEMY
    j LET_IT_ALIVE
    KILL_ENEMY:
        # causar dano
        la t0 ENEMY_HP
        slli t1 t6 2
        add t0 t0 t1
        lw t2 0(t0)
        ble t2 zero LET_IT_ALIVE

        # add enemy to hurt list and skip if its already hurt
        # remember to reset that list after the state_atack
        la t2 ENEMY_HURT
        slli t1 t6 2
        add t2 t2 t1
        lw t3 0(t2)
        li t1 1
        sw t1 0(t2)
        bnez t3 LET_IT_ALIVE

        lw t1 0(t0)
        add t1 t1 s4 # causar dano ao hp do inimigo
        sw t1 0(t0)
        bgt t1 zero LET_IT_ALIVE

        # se a vida do inimigo chegar à 0 -> mata-lo
        la t0 ENEMY_IS_ALIVE
        slli t1 t6 2
        add t0 t0 t1

        lw t1 0(t0)
        beqz t1 LET_IT_ALIVE

        sw zero 0(t0)

    LET_IT_ALIVE:

    addi t6 t6 1
    blt t6 a3 ENEMY_HIT_LOOP

    ret

    SKIP_ATK_FRAME:
        la s0 alucard_idle
        li s1 0 # reseta o valor do sprite
        li s3 0 # volta para o state idle

        # reset enemy_hurt vector
        la t0 NUM_ENEMIES
        lw t0 0(t0)
        li t1 0
        la t3 ENEMY_HURT
        RESET_ENEMY_HURT:
            slli t2 t1 2
            add t3 t3 t2
            sw zero 0(t3)

            addi t1 t1 1
        blt t1 t0 RESET_ENEMY_HURT
        #j AFTER_STATE_FREE
    ret

j GAME_LOOP