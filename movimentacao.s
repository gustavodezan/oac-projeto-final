.data
.include "./assets/teste_mapa.s"
.text
# lógica de movimentação:

# Movimentação horizontal:
# normal

# Movimentação vertical:
# o player é acelarado para baixo sempre que não estiver em contato com o chão (de acordo com a gravidade)

# pulo: quando pular, ele deve manter a aceleração horizontal durante o período de aceleração vertical
# força = jump_force

# a0 -> vetor posição do player
# a1 -> vetor velocidade do player
MOVIMENTAR_HORIZONTAL:
    lw t0 0(a0)
    lw t1 0(a1)
    add t2 t1 t0
    sw t2 0(a0)
    ret

MOV_DIREITA:
    la a0 teste_mapa
    li a1 0
    li a2 0
    li a3 320
    call RENDER

    
    la a0 RichterBelmont
	la a1 PLAYER_XY
    lw a1 0(a1)

	li a2 96
	li a2 48
	li a3 24
    call RENDER
    j MOVIMENTAR

MOV_ESQUERDA:
    la a0 teste_mapa
    li a1 0
    li a2 0
    li a3 320
    call RENDER

    la a0 RichterBelmont
	la a1 PLAYER_XY
    lw a1 0(a1)
	li a2 96
	li a2 48
	li a3 24
    call RENDER_INVERT
    j MOVIMENTAR

GRAVIDADE:
    lw t0 4(a0)
    lw t1 4(a1)
    add t2 t1 t0
    sw t2 4(a0)
    ret

# ---------------------------
# Colisao
# ---------------------------
# Existirá uma imagem "vetor_colisao". O player terá uma hitbox
# Para colidir o player com a matriz de colisao basta verificar os 4 pixeis exteriores da hitbox

# a0 matriz de colisão
# a1 -> x do sprite
# a2 -> y do sprite
# a3 -> vetor posição do obj
# a4 -> direção do movimento
# ponto 1
# -> a3
CHECK_COLLISION:
addi a2 a2 4
li t0 4
mul t0 a4 t0 
add a1 a1 t0

lw t0 0(a3) # t0 -> x do obj
mv t1 a0
addi t1 t1 8
add t1 t1 t0
lw t0 0(t1)
li t6 -1
bne t0 t6 COLIDE

# ponto 2
lw t0 0(a3) # t0 -> x do obj
mv t1 a0 # t1 -> vetor da matriz de colisao
add t0 t0 a1 # t0 -> x do obj + x do sprite
addi t1 t1 8
add t1 t1 t0
lw t0 0(t1)
li t6 -1
bne t0 t6 COLIDE

# ponto 3
# li t2 320
# mul t2 t2 a2 # y do sprite * 320
# add t2 a1 t2 # soma x do sprite + y do sprite * 320 -> pos do sprite

# lw t0 0(a3) # t0 -> x do obj
# mv t1 a0
# li t2 320
# mul t2 t2 a2 # pos + y do sprite
# add t2 a1 t2
# add t0 t0 t2
# addi t1 t1 8
# add t1 t1 t0
# lw t0 0(t1)
# li t6 -1
# bne t0 t6 COLIDE

# ponto 4
li t2 320
mul t2 t2 a2 # pos + y do sprite
add t2 a1 t2

lw t0 0(a3) # t0 -> x do obj
mv t1 a0
li t2 320
mul t2 t2 a2 # pos + y do sprite
add t2 a1 t2
add t0 t0 t2
addi t1 t1 8
add t1 t1 t0
lw t0 0(t1)
li t6 -1
#bne t0 t6 COLIDE

ret
COLIDE:
    # CHECAR TIPO DE COLISAO
    j END_CHECK_INPUT
