.data
ENEMY_XY: .word 320, 120
ENEMY_IS_ALIVE: 1
.text

ENEMY_PROCEDURE:
# Create the logic to find if enemy's on the screen (and how many pixels of it's on the screen)
# and print it

CHECK_IF_ENEMY_ON_SCREEN:
    # check if enemy is alive
    la t0 ENEMY_IS_ALIVE
    lw t0 0(t0)
    beqz t0 SKIP_ENEMY_RENDER

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

    la a0 RichterBelmont
    la t0 ENEMY_XY
    lw t1 0(t0)
    lw t2 4(t0)
    
    la t3 CAMERA_XY
    lw t3 0(t3)
    sub t1 t1 t3

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

j GAME_LOOP