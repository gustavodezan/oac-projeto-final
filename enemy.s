.text

ENEMY_PROCEDURE:
# Create the logic to find if enemy's on the screen (and how many pixels of it's on the screen)
# and print it
# check if enemy is alive
li s7 0
ENEMY_PROC_LOOP:
    
    la t0 ENEMY_IS_ALIVE

    slli t1 s7 2
    add t0 t0 t1

    lw t0 0(t0)
    beqz t0 SKIP_ENEMY_FULL

    CHECK_IF_ENEMY_ON_SCREEN:
        # conferir se x do inimigo está entre x_camera e x_camera-320
        la t0 ENEMY_XY

        slli t1 s7 3
        add t0 t0 t1

        lw t1 0(t0)
        lw t2 4(t0)
        
        la t3 CAMERA_XY
        lw t3 0(t3)
        blt t1 t3 SKIP_ENEMY_RENDER
        addi t3 t3 320
        bgt t1 t3 SKIP_ENEMY_RENDER

        # converter a posição do inimigo para uma posição na tela e renderizar
        #la a0 teste_enemy
        la t0 ENEMY_XY

        slli t1 s7 3
        add t0 t0 t1

        lw t1 0(t0)
        lw t2 4(t0)
        li t3 320
        mul t3 t3 t2
        add a1 t3 t1
        
        la t0 ENEMY_FRAME
        slli t1 s7 3
        add t0 t0 t1
        lw t0 0(t0)
        li t1 16
        mul a2 t1 t0

        li a3 16
        la a4 camera
        addi a4 a4 8

        la a0 morcego
        la t0 ENEMY_XY

        slli t1 s7 3
        add t0 t0 t1

        lw t1 0(t0)
        lw t2 4(t0)
        
        la t3 CAMERA_XY
        lw t3 0(t3)
        sub t1 t1 t3

        li t3 320
        mul t3 t3 t2
        add a1 t3 t1
        li a2 0
        la t0 ENEMY_FRAME
        slli t1 s7 3
        add t0 t0 t1
        lw t0 0(t0)
        li t1 16
        mul a2 t1 t0

        li a3 16
        la a4 camera
        addi a4 a4 8
        call RENDER_ON_CAMERA
        SKIP_ENEMY_RENDER:
        
        # aproximar o x e o y do inimigo do y do player e do x do inimigo
        la t0 ENEMY_XY
        slli t1 s7 3
        add t0 t0 t1

        lw t1 0(t0)
        lw t2 4(t0)
        
        la t3 CAMERA_XY
        lw t3 0(t3)
        addi t3 t3 144
        
        la t6 PLAYER_XY
        lw t6 4(t6)

        sub t4 t1 t3 # diferença entre x_inimigo - x_camera
        sub t5 t2 t6 # diferença entre y_inimigo - y_camera
        li t6 16
        bgeu t4 t6 DONT_DAMAGE_ALUCARD_YET

        bleu t5 t6 DAMAGE_ALUCARD
        DONT_DAMAGE_ALUCARD_YET:
        bgtz t4 SUB_DISTANCE_X
            addi t1 t1 4
            sw t1 0(t0)
            j END_ENEMY_MOVEMENT_X
        SUB_DISTANCE_X:
            addi t1 t1 -4
            sw t1 0(t0)
        END_ENEMY_MOVEMENT_X:

            la t3 PLAYER_XY
            lw t3 4(t3)   
            addi t3 t3 0
            sub t4 t2 t3 # diferença entre y_inimigo - y_camera
            bgtz t4 SUB_DISTANCE_Y
            addi t2 t2 4
            sw t2 4(t0)
            j END_ENEMY_MOVEMENT_Y
        SUB_DISTANCE_Y:
            addi t2 t2 -4
            sw t2 4(t0)
        END_ENEMY_MOVEMENT_Y:

        # Damage Alucard:
        # check if enemy is melee with alucard
        j ANIMATE_ENEMY
        DAMAGE_ALUCARD:
            la t0 ENEMY_DAMAGE
            slli t1 s7 3
            add t0 t0 t1
            lw t1 0(t0)
            bnez t1 SKIP_DAMAGING_ALUCARD

            j SOUND_HURTED
            AFTER_SOUND_HURTED:

            li t1 1
            sw t1 0(t0)

            la t0 PLAYER_HP
            lw t1 0(t0)
            addi t1 t1 -3
            sw t1 0(t0)
            j ANIMATE_ENEMY

            SKIP_DAMAGING_ALUCARD:

        ANIMATE_ENEMY:
            la t0 ENEMY_FRAME
            slli t1 s7 3
            add t0 t0 t1
            lw t2 4(t0)
            lw t1 0(t0)
            bge t1 t2 RESET_ENEMY_FRAME
                addi t1 t1 1
                sw t1 0(t0)
                j END_ENEMY_ANIMATION
            RESET_ENEMY_FRAME:
            sw zero 0(t0)
            CLEAN_ENEMY_DAMAGE_LIST:
            la t0 ENEMY_DAMAGE
            slli t1 s7 2
            add t0 t0 t1
            sw zero 0(t0)
        END_ENEMY_ANIMATION:

    SKIP_ENEMY_FULL:

    la t5 NUM_ENEMIES
    lw t5 0(t5)
    addi s7 s7 1
    blt s7 t5 ENEMY_PROC_LOOP

j END_CHECK_IF_ENEMY_ON_SCREEN
j AFTER_ENEMY_PROCEDURE

j GAME_LOOP