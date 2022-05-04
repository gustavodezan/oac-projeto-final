# Propagar o poder
POWER_PROC:
    PROPAGATE_POWER:
        la t0 POWER
        lw t1 4(t0)
        lw t2 12(t0)
        li t3 2
        mul t3 t3 t2
        add t1 t1 t3
        sw t1 4(t0)


    DESTROY_ENEMIES:
    # HIT LOOP
    li t6 0 # contador de inimigos
    la a3 NUM_ENEMIES
    lw a3 0(a3)
    SEARCH_FOR_TARGETS_LOOP:
    la t0 ENEMY_XY
    # deslocar ponteiro de inimigo
    slli t1 t6 3
    add t0 t0 t1

    lw t1 0(t0) # l1.x
    lw t2 4(t0) # l1.y
    # Procurar por inimigos
    CHECK_HIT_X_POWER:
        mv t3 t1
        # checar se o inimigo está no mesmo x que o personagem
        la t4 POWER
        lw t4 4(t4) # x do poder
        addi t5 t5 144
        addi t5 t5 16
        bge t3 t5 LET_IT_ALIVE_POWER
        addi t5 t5 -16
        addi t3 t3 8
        ble t3 t5 LET_IT_ALIVE_POWER

    j CHECK_HIT_Y_POWER

    CHECK_HIT_LEFT_X_POWER:
        sub t2 zero t2 # deixa o range negativo
        mv t3 t1
        # checar se o inimigo está no mesmo x que o personagem
        la t5 POWER
        lw t5 4(t5) # carregar o x da câmera em t5
        addi t5 t5 144
        addi t5 t5 -16
        bge t5 t3 LET_IT_ALIVE_POWER
        addi t5 t5 16
        addi t3 t3 16
        ble t5 t3 LET_IT_ALIVE_POWER

    CHECK_HIT_Y_POWER:
    la t0 ENEMY_XY
    # deslocar ponteiro de inimigo
    slli t1 t6 3
    add t0 t0 t1

    # se o inimigo estiver no mesmo x que o personagem, checar se ele stá no mesmo y
    lw t2 4(t0) # l1.y
    mv t3 t2
    la t4 POWER
    lw t5 8(t4)

    addi t5 t5 16
    ble t5 t3 KILL_ENEMY_POWER
    addi t5 t5 -16
    addi t3 t2 16
    ble t5 t3 KILL_ENEMY_POWER
    j LET_IT_ALIVE

    KILL_ENEMY_POWER:
        # causar dano
        la t0 ENEMY_HP
        slli t1 t6 2
        add t0 t0 t1
        lw t2 0(t0)
        ble t2 zero LET_IT_ALIVE_POWER

        # add enemy to hurt list and skip if its already hurt
        # remember to reset that list after the state_atack

        lw t1 0(t0)
        add t1 t1 s5 # causar dano ao hp do inimigo
        sw t1 0(t0)

        la t6 POWER
        sw zero 0(t6)

        bgt t1 zero LET_IT_ALIVE

        # se a vida do inimigo chegar à 0 -> mata-lo
        la t0 ENEMY_IS_ALIVE
        slli t1 t6 2
        add t0 t0 t1

        lw t1 0(t0)
        beqz t1 LET_IT_ALIVE

        sw zero 0(t0)

    LET_IT_ALIVE_POWER:

    la t0 POWER
    lw t0 0(t0)
    beqz t0 END_POWER_LOOP

    addi t6 t6 1
    blt t6 a3 SEARCH_FOR_TARGETS_LOOP

    END_POWER_LOOP:

    j AFTER_POWER