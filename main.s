.data
# Player data
PLAYER_XY: 0,0
PLAYER_XY_ACL: 10,0

# Input
INPUT: 0
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)

.eqv w 119
.eqv a 97
.eqv s 115
.eqv d 100
.text
# --------------------------------------
# Dividir o game loop em menu e in-game
# --------------------------------------

GAME_LOOP:
    # zerar xlr8 horizontal
    la t0 PLAYER_XY_ACL
    sw zero 0(t0)
    
    # adicionar gravidade

    # implementando chamada de movimento
    INPUT_LOOP:
        li t0, MMIO_set # ready bit MMIO
        lb t1,(t0)
	beqz t1 END_CHECK_INPUT # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
    la t0 INPUT
    sw a0 0(t0) # Salva o valor de MMIO no endereço de INPUT
    # gerenciar input
    # j INPUT_MANAGER
    # AFTER_INPUT
    j CHECK_INPUT

    END_CHECK_INPUT:

    # MOVIMENTAR
    MOVIMENTAR:
    la a0 PLAYER_XY
    la a1 PLAYER_XY_ACL
    call MOVIMENTAR_HORIZONTAL
j GAME_LOOP

CHECK_INPUT:
    la a0 teste_mapa
    li a1 24
    li a2 48
    la a3 PLAYER_XY
    call CHECK_COLLISION

    la a0 INPUT
    lw t0, 0(a0)
    li t1 w
    bne t0, t1, NEXT_A

    call CHECK_COLLISION

    la a0 PLAYER_XY_ACL
    li t0 -320
    sw t0 0(a0)
    la a0 PLAYER_XY
    la a1 PLAYER_XY_ACL
    call MOVIMENTAR_HORIZONTAL
    j MOV_DIREITA

    NEXT_A:
    li t1 a
    bne t0 t1 NEXT_S

    call CHECK_COLLISION

    la a0 PLAYER_XY_ACL
    li t0 -10
    sw t0 0(a0)
    la a0 PLAYER_XY
    la a1 PLAYER_XY_ACL
    call MOVIMENTAR_HORIZONTAL
    j MOV_ESQUERDA

    NEXT_S:
    li t1 s
    bne t0 t1 NEXT_D

    call CHECK_COLLISION

    la a0 PLAYER_XY_ACL
    li t0 320
    sw t0 0(a0)
    la a0 PLAYER_XY
    la a1 PLAYER_XY_ACL
    call MOVIMENTAR_HORIZONTAL
    j MOV_DIREITA

    NEXT_D:
    li t1 d
    bne t0 t1 END_CHECK_INPUT

    call CHECK_COLLISION

    la a0 PLAYER_XY_ACL
    li t0 10
    sw t0 0(a0)
    la a0 PLAYER_XY
    la a1 PLAYER_XY_ACL
    call MOVIMENTAR_HORIZONTAL
    j MOV_DIREITA

    j END_CHECK_INPUT

.include "./movimentacao.s"
.include "./player.s"