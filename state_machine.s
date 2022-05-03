STATE_DOWN:
    la t0 STATE_MACHINE
    lw t1 0(t0)
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
    
        # carrega frame atual em 
        la t2 ATTACK_FRAMES
        lw t0 0(t2)
        li t1 4

        bge t0 t1 SKIP_ATK_FRAME

        mv s1 t0
        addi t0 t0 1
        sw t0 0(t2)

    j AFTER_STATE_ATTACK

    SKIP_ATK_FRAME:
        la t2 STATE_MACHINE
        sw zero 0(t2)
        j AFTER_STATE_ATTACK