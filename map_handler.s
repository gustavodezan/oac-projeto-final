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

NEXT_MAP:
    la t0 ACTUAL_MAP
    lw t0 0(t0)
    addi t0 t0 1
    lw t1 4(t0)
    bge t0 t1 SKIP_NEXT_MAP_PROC
    sw t0 0(t0)

    SKIP_NEXT_MAP_PROC:
j GAME_LOOP