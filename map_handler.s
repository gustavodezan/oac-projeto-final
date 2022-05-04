.text
MAP_SELECTOR:
    la a0 ACTUAL_MAP
    lw a0 0(a0)
    slli t2 a0 2
    la a0 MAPS
    add a0 a0 t2
    lw a0 0(a0)
    ret

MAP_COL_SELECTOR:
    la a1 ACTUAL_MAP
    lw a1 0(a1)
    slli t0 a1 2
    la a1 MAPS_COL
    add a1 a1 t0
    lw a1 0(a1)
    ret

CHECK_IF_NEXT_MAP:
    la t0 ACTUAL_MAP
    lw t1 0(t0)
    bnez t1 CHECK_MAP1
        la t1 CAMERA_XY
        lw t1 0(t1)
        addi t1 t1 144
        li t2 1900
        bge t1 t2 NEXT_MAP

    CHECK_MAP1:
    li t1 1
j AFTER_CHECK_IF_NEXT_MAP

NEXT_MAP:
    la t1 ACTUAL_MAP
    lw t2 0(t1)
    addi t2 t2 1
    sw t2 0(t1)
    # set up next map properties
    la t0 CAMERA_XY
    li t1 20
    sw t1 0(t0)

    SKIP_NEXT_MAP_PROC:
j GAME_LOOP

START_GAME:
    la t1 NUM_ENEMIES0
    lw t1 0(t1)
    la t0 NUM_ENEMIES
    sw t1 0(t0)
    li t0 0
    START_GAME_LOOP:
        slli t4 t0 2 # mult t0 por 4
        la t2 ENEMY_IS_ALIVE
        add t2 t2 t4
        li t3 1
        sw t3 0(t2)

        la t2 ENEMY_HP
        la t3 ENEMY_HP0
        add t3 t3 t4
        add t2 t2 t4
        lw t3 0(t3)
        sw t3 0(t2)
        
        la t2 ENEMY_TYPE
        la t3 ENEMY_TYPE0
        add t3 t3 t4
        add t2 t2 t4
        lw t3 0(t3)
        sw t3 0(t2)

        slli t4 t0 3 # mult t0 por 8
        la t2 ENEMY_XY
        la t3 ENEMY_XY0
        add t3 t3 t4
        add t2 t2 t4
        lw t5 0(t3)
        sw t5 0(t2)
        lw t5 4(t3)
        sw t5 4(t2)

        addi t0 t0 1
    blt t0 t1 START_GAME_LOOP
ret