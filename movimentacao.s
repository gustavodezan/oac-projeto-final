.data
.include "./assets/teste_mapa.s"
.include "./assets/entrance_col.s"
.include "./assets/entrance_pedra_top_col.s"
.text
# lógica de movimentação:

# Movimentação horizontal:
# normal

# Movimentação vertical:
# o player é acelarado para baixo sempre que não estiver em contato com o chão (de acordo com a gravidade)

# pulo: quando pular, ele deve manter a aceleração horizontal durante o período de aceleração vertical
# força = jump_force

# ---------------------------
# Colisao
# ---------------------------
# checar se o personagem colide com as bordas do mapa:
# pegar posição do personagem e sobrepor com o mapa de colisão
# vai usar muito acesso á memória... :(
# a posição do personagem está no vetor PLAYER_XY
# basta checar qual é a fase e qual é o mapa.

# a0 -> PLAYER_XY
# a1 -> map_collision
# a2 -> CAMERA_XY
# a3 -> increment position
# colisão vertial:
# retorna 1 se colide com o chão, 2 se colide com escada
COLIDE_VERTICAL:
    # la a0 PLAYER_XY
    lw t0 4(a0) # pos y do player
    add t0 t0 a3 # valor de incremento

    li t1 1
    sub t0 t0 t1

    li t1 48
    add t0 t0 t1

    lw t1 0(a1) # len(x) do mapa
    mul t0 t0 t1

    la a2 CAMERA_XY
    li t1 144
    add t0 t0 t1
    lw t1 0(a2)
    add t0 t0 t1

    # add to map vector
    li t2 8
    add t3 a1 t2
    add t3 t3 t0
    lb t0 0(t3)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_V
    li t4 7
    beq t0 t4 COLIDED_V
    bgtz t0 COLIDED_V

    # se não colidir no pixel mais à esquerda, colidir no pixel à direita
    lw t0 4(a0) # pos y do player
    add t0 t0 a3 # valor de incremento

    li t1 1
    sub t0 t0 t1

    li t1 48
    add t0 t0 t1

    lw t1 0(a1) # len(x) do mapa
    mul t0 t0 t1

    la a2 CAMERA_XY
    li t1 144
    add t0 t0 t1
    lw t1 0(a2)
    add t0 t0 t1
    addi t0 t0 48

    # add to map vector
    li t2 8
    add t3 a1 t2
    add t3 t3 t0
    lb t0 0(t3)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_V
    li t4 7
    beq t0 t4 COLIDED_V
    bgtz t0 COLIDED_V

li a0 0
ret
COLIDED_V:

    li t1 55
    bne t1 t0 CHECK_NEXT_COL_TYPE_Y
        j NEXT_MAP
    CHECK_NEXT_COL_TYPE_Y:
    li a0 1
    ret

# mesmo procedimento que do vertical comum, mas quando colide com 56 y_speed vira 0
COLIDE_VERTICAL_UP:
    # la a0 PLAYER_XY
    lw t0 4(a0) # pos y do player
    add t0 t0 a3 # valor de incremento

    li t1 1
    sub t0 t0 t1

    li t1 48
    #add t0 t0 t1

    lw t1 0(a1) # len(x) do mapa
    mul t0 t0 t1

    li t1 144
    add t0 t0 t1

    # add to map vector
    li t2 8
    add t3 a1 t2
    add t3 t3 t0
    lb t0 0(t3)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_V_UP
    li t4 7
    beq t0 t4 COLIDED_V_UP
    bgtz t0 COLIDED_V_UP

    # se não colidir no pixel mais à esquerda, colidir no pixel à direita
    lw t0 4(a0) # pos y do player
    add t0 t0 a3 # valor de incremento

    li t1 1
    sub t0 t0 t1

    li t1 48
    #add t0 t0 t1

    lw t1 0(a1) # len(x) do mapa
    mul t0 t0 t1

    li t1 144
    add t0 t0 t1
    li t3 48
    add t0 t0 t3

    # add to map vector
    li t2 8
    add t3 a1 t2
    add t3 t3 t0
    lb t0 0(t3)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_V_UP
    li t4 7
    beq t0 t4 COLIDED_V_UP
    bgtz t0 COLIDED_V_UP


li a0 0
ret
COLIDED_V_UP:
    # mv a0 t0
    # li a7 1
    # ecall
    # la a0 SPACE
    # li a7 4
    # ecall

    li t1 55
    bne t1 t0 CHECK_NEXT_COL_TYPE_Y
        j NEXT_MAP
    CHECK_NEXT_COL_TYPE_Y:

    la t0 Y_SPEED
    fmv.s.x ft0 zero
    fsw ft0 0(t0)

    la t0 JUMP_DIR
    sw zero 0(t0)
    sw zero 4(t0)

    li a0 1
    ret

# -------------------
# Colisão Horizontal
# -------------------
# a0 -> PLAYER_XY
# a1 -> map_collision
# a2 -> CAMERA_XY
# a3 -> increment position
# la a0 PLAYER_XY
COLIDE_HORIZONTAL_RIGHT:
    lw t0 4(a0) # pos y do player

    li t1 48
    add t0 t0 t1 # altura do sprite
    addi t0 t0 -1

    lw t1 0(a1) # len(x) do mapa
    mul t0 t0 t1

    # parte horizontal
    li t1 144
    add t0 t0 t1
    add t0 t0 a3 # valor de incremento

    # adicionar largura do sprite
    li t1 40
    add t0 t0 t1

    # adicionar camera
    lw t1 0(a2)
    add t0 t0 t1

    # add to map vector
    li t2 8
    add t3 a1 t2
    add t3 t3 t0
    lb t0 0(t3)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_H
    li t4 7
    beq t0 t4 COLIDED_H
    #bgtz t0 COLIDED_H

    # check head collision
    # lw t0 4(a0) # pos y do player

    # li t1 48
    # add t0 t0 t1 # altura do sprite
    # addi t0 t0 -1

    # lw t1 0(a1) # len(x) do mapa
    # mul t0 t0 t1

    # # parte horizontal
    # li t1 144
    # add t0 t0 t1
    # add t0 t0 a3 # valor de incremento

    # # adicionar largura do sprite
    # li t1 40
    # add t0 t0 t1

    # # adicionar camera
    # lw t1 0(a2)
    # add t0 t0 t1

    # # add to map vector
    # li t2 8
    # add t3 a1 t2
    # add t3 t3 t0
    # lb t0 0(t3)

    # li t4 943208504
    # li t4 56
    # beq t0 t4 COLIDED_H
    # li t4 7
    # beq t0 t4 COLIDED_H
    # bgtz t0 COLIDED_V_UP


li a0 0
ret
COLIDED_H:
    # mv a0 t0
    # li a7 1
    # ecall
    # la a0 SPACE
    # li a7 4
    # ecall

    li t1 7
    bne t1 t0 CHECK_MAP_COL_TYPE_X
        la t3 PLAYER_DIR
        lw t3 0(t3)
        beqz t3 UP_DIR
        la t1 PLAYER_XY
        lw t2 4(t1)
        addi t2 t2 -3
        sw t2 4(t1)

        la t1 CAMERA_XY
        lw t2 0(t1)
        addi t2 t2 -2
        sw t2 0(t1)
        ret

        UP_DIR:
        la t1 PLAYER_XY
        lw t2 4(t1)
        addi t2 t2 -4
        sw t2 4(t1)

        la t1 CAMERA_XY
        lw t2 0(t1)
        addi t2 t2 2
        sw t2 0(t1)
        ret

    CHECK_MAP_COL_TYPE_X:
    
    li t1 55
    bne t1 t0 CHECK_NEXT_COL_TYPE_Y
        j NEXT_MAP
    CHECK_NEXT_COL_TYPE_Y:

    li a0 1
    ret


COLIDE_HORIZONTAL_LEFT:
    lw t0 4(a0) # pos y do player

    li t1 48
    add t0 t0 t1 # altura do sprite
    addi t0 t0 -8

    lw t1 0(a1) # len(x) do mapa
    mul t0 t0 t1

    # parte horizontal
    li t1 144
    add t0 t0 t1
    add t0 t0 a3 # valor de incremento
    # adicionar camera
    lw t1 0(a2)
    add t0 t0 t1

    # add to map vector
    li t2 8
    add a1 a1 t2
    add a1 a1 t0
    lb t0 0(a1)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_H
    li t4 7
    beq t0 t4 COLIDED_H
    #bgtz t0 COLIDED_H

li a0 0
ret

j GAME_LOOP