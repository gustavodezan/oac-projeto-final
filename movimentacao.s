.data
.include "./assets/teste_mapa.s"
.include "./assets/entrance_col.s"
.text
# lógica de movimentação:

# Movimentação horizontal:
# normal

# Movimentação vertical:
# o player é acelarado para baixo sempre que não estiver em contato com o chão (de acordo com a gravidade)

# pulo: quando pular, ele deve manter a aceleração horizontal durante o período de aceleração vertical
# força = jump_force


# COLLIDE_VERTICAL:
    # # start checking left coll
    # # la a0 PLAYER_XY
    # # la a1 map_collision
    # la a2 CAMERA_XY

    # # position obj in camera x and add 144 to it
    # lw t0 0(a2)
    # li t1 144
    # add t4 t0 t1

    # # get y position of player
    # lw t0 4(a0)
    # li t1 2008
    # mul t0 t0 t1
    # add t0 t0 t4 # final dis

    # # add the value to colision map
    # li t1 8
    # add t0 t0 t1
    # add a1 a1 t0
    # lw t3 0(a1)
    
    # li t6 943208504
    # beq t3 t6 COLIDED_V

    # # check right coll

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

    li t1 144
    add t0 t0 t1

    # add to map vector
    li t2 8
    add a1 a1 t2
    add a1 a1 t0
    lb t0 0(a1)

    li t4 943208504
    li t4 56
    beq t0 t4 COLIDED_V
    li t4 7
    beq t0 t4 COLIDED_V
    bgtz t0 COLIDED_V

    # mv a0 t0
    # li a7 1
    # ecall
    # la a0 SPACE
    # li a7 4
    # ecall

li a0 0
ret
COLIDED_V:
    
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
COLIDED_H:
    # mv a0 t0
    # li a7 1
    # ecall
    # la a0 SPACE
    # li a7 4
    # ecall

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