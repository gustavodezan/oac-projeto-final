.text
	# a0 -> sprite
    # a1 -> valor a adicionar no vetor
    # a2 -> vetor de frame
	# a3 -> num pixeis em x de cada sprite
	#j RENDER_INVERT
	# RENDER MAP
	RENDER:
	lw t0 0(a0) # x da imagem
 	lw t1 4(a0) # y
	sub t0 t0 a3 # x da imagem - num pixeis em x de cada sprite -> valor para pular no arquivo da imagem
	mul t6 t1 a3 # area
	addi a0 a0 8
	add a0 a0 a2
	li t3 0
	li t4 0
	li t2 0xFF000000
	add t2 t2 a1
	RENDER_LOOP:
		lw t5 0(a0)
		sw t5 0(t2)
		addi a0 a0 4
		addi t2 t2 4
		addi t3 t3 4
		addi t4 t4 4
		bge t4 a3 NEW_LINE
	AFTER_NEW_LINE:
		blt t3 t6 RENDER_LOOP
	END_RENDER:
		ret
	NEW_LINE:
		li t4 320
		sub t4 t4 a3
		add t2 t2 t4
		add a0 a0 t0
		li t4 0
		j AFTER_NEW_LINE

	EXIT:
		ret
		li a7 5
		ecall

# renderiza o todos os objetos da tela no vetor "câmera" no lugar do bitmap display
# (para posteriormente o bitmap simplesmente renderizar o objeto câmera)
# lê byte à byte
# o transparente é pulado na hora de passar para o objeto câmera
RENDER_ON_CAMERA:
	lw t0 0(a0) # x da imagem
 	lw t1 4(a0) # y
	sub t0 t0 a3 # x da imagem - num pixeis em x de cada sprite -> valor para pular no arquivo da imagem
	mul t6 t1 a3 # area
	addi a0 a0 8
	add a0 a0 a2
	li t3 0
	li t4 0
	mv t2 a4
	add t2 t2 a1
	li a5 -57 # valor do transparente
	# adicionar procedimento que pula as linhas e colunas de pixeis que estiverem fora da tela

	RENDER_CAM_LOOP:
		lb t5 0(a0)
		beq t5 a5 SKIP_PIXEL_ADD
		sb t5 0(t2)

		SKIP_PIXEL_ADD:
		addi a0 a0 1
		addi t2 t2 1
		addi t3 t3 1
		addi t4 t4 1
		bge t4 a3 NEW_LINE_CAM
	AFTER_NEW_LINE_CAM:
		blt t3 t6 RENDER_CAM_LOOP
	END_RENDER_CAM:
		ret
	NEW_LINE_CAM:
		li t4 320
		sub t4 t4 a3
		add t2 t2 t4
		add a0 a0 t0
		li t4 0
		j AFTER_NEW_LINE_CAM

	EXIT_CAM:
		ret


# render invert
RENDER_ON_CAMERA_INVERT:
	lw t0 0(a0) # x da imagem
 	lw t1 4(a0) # y
	#sub t0 t0 a3 # x da imagem - num pixeis em x de cada sprite -> valor para pular no arquivo da imagem
	sub t0 t0 a3 # sub x da imagem de x
	
	mul t6 t1 a3 # area com base no tamanho do sprite
	addi a0 a0 8

	add a0 a0 a3 # pula para o final do sprite

	add a0 a0 a2
	li t3 0
	li t4 0
	mv t2 a4
	add t2 t2 a1
	add t2 t2 a3 # add em t2 o x do sprite
	li a5 -57 # valor do transparente
	# adicionar procedimento que pula as linhas e colunas de pixeis que estiverem fora da tela

	RENDER_CAM_LOOP_INVERT:
		lb t5 0(a0)
		beq t5 a5 SKIP_PIXEL_ADD_INVERT
		sb t5 0(t2)

		SKIP_PIXEL_ADD_INVERT:
		addi a0 a0 1
		addi t2 t2 -1
		addi t3 t3 1
		addi t4 t4 1
		bge t4 a3 NEW_LINE_CAM_INVERT
	AFTER_NEW_LINE_CAM_INVERT:
		blt t3 t6 RENDER_CAM_LOOP_INVERT
	END_RENDER_CAM_INVERT:
		ret
	NEW_LINE_CAM_INVERT:
		li t4 320
		add t4 t4 a3
		add t2 t2 t4
		add a0 a0 t0
		li t4 0
		j AFTER_NEW_LINE_CAM_INVERT

	EXIT_CAM_INVERT:
		ret




IS_ON_CAMERA:

# -------------------------
# Processo de renderização
# -------------------------
# printar o mapa sobre a câmera
# em seguida printar o personagem
# por fim os montros
RENDER_PROCCESS:
    # renderizar mapa
    
    #la a0 entrance
	call MAP_SELECTOR # returns in a0 map and in a1 map_col
	#la a0 entrance_col
	li a1 0
    la a2 CAMERA_XY
    lw a2, 0(a2)
    li a3 960
    lw a3 0(a0)
    la a4 camera
    addi a4 a4 8
    call RENDER_ON_CAMERA

    # ...
    # Objects
    # ...
	j ENEMY_PROCEDURE
    END_CHECK_IF_ENEMY_ON_SCREEN:

	# weapon
	# checar se esta com a espada equipada
	la t0 INVENTORY
	lw t0 0(t0) # conferir o que está equipado na mão 1
	li t1 1
	bne t0 t1 AFTER_WEAPON_RENDER

	# checar se esta no frame correto
	li t0 1
	bne t0 s3 AFTER_WEAPON_RENDER
	li t1 2
	bgt s1 t1 AFTER_WEAPON_RENDER
	li t1 0
	blt s1 t1 AFTER_WEAPON_RENDER
	la a0 alucard_sword
	#li a1 44000
	la t0 PLAYER_XY
	lw t0 4(t0)
	addi t0 t0 -16
	li t1 320
	mul t0 t0 t1
	addi a1 t0 160

    li a2 80
	addi t0 s1 0
	mul a2 a2 t0
    li a3 80
    la a4 camera
    addi a4 a4 8

	la t0 PLAYER_DIR
    lw t0 0(t0)

    # if player dir == 0 -> render normal, else render invertido
    bnez t0 RENDER_WEAPON_INVERT
    call RENDER_ON_CAMERA
    j AFTER_WEAPON_RENDER
    RENDER_WEAPON_INVERT:
	#li a1 46560
	la t0 PLAYER_XY
	lw t0 4(t0)
	addi t0 t0 -16
	li t1 320
	mul t0 t0 t1
	addi a1 t0 160

	li t1 2560
	add a1 a1 t1
	addi a1 a1 -56
	li a2 80
	addi t0 s1 -1
	mul a2 a2 t0
    call RENDER_ON_CAMERA_INVERT
    AFTER_WEAPON_RENDER:

	# Render Power
	# check if power exists
	la t0 POWER
	lw t0 0(t0)
	beqz t0 THERES_NO_POWER_HERE

	la a0 python
	li a1 0

	la t0 POWER
	lw t0 8(t0)
	
	li t1 320
	mul t0 t0 t1

	la t2 POWER
	lw t2 4(t2)

	add t0 t0 t2

	# la t1 CAMERA_XY
	# lw t1 0(t1)
	# sub t0 t0 t1

	# bgez t0 CONTINUE_POWER_PRINT
	# 	sub t0 zero t0
	CONTINUE_POWER_PRINT:

	addi a1 t0 16

	li a2 0
	li a3 16
	la a4 camera
    addi a4 a4 8
	call RENDER_ON_CAMERA

	THERES_NO_POWER_HERE:

    # Player
    mv a0 s0
    la t0 PLAYER_XY
    lw t1 0(t0)
    lw t2 4(t0)
    li t3 320
    mul t3 t3 t2
    add a1 t3 t1 
    lw a3 4(a0)

    # define frame
    mv a2 s1
    mul a2 a2 a3

    la a4 camera
    addi a4 a4 8

    la t0 PLAYER_DIR
    lw t0 0(t0)

    # if player dir == 0 -> render normal, else render invertido
    bnez t0 RENDER_PLAYER_INVERT
    call RENDER_ON_CAMERA
    j AFTER_PLAYER_RENDER
    RENDER_PLAYER_INVERT:
    call RENDER_ON_CAMERA_INVERT

    AFTER_PLAYER_RENDER:


	la a0 health_bar
	li a1 0
	la t0 PLAYER_HP
	lw t2 0(t0) # atual
	li t1 60
	li a2 0
	bgt t2 t1 NEXT_HP_STAGE
		li a2 0

	NEXT_HP_STAGE: 
	li t1 50
	bgt t2 t1 NEXT_HP_STAGE2
		li a2 104
	NEXT_HP_STAGE2:
	li t1 40
	bgt t2 t1 NEXT_HP_STAGE3
		li a2 208
	NEXT_HP_STAGE3: 
	li t1 30
	bgt t2 t1 NEXT_HP_STAGE4
		li a2 312
	NEXT_HP_STAGE4: 
	li t1 10
	bgt t2 t1 NEXT_HP_STAGE5
		li a2 416
	NEXT_HP_STAGE5: 
	li t1 0
	bgt t2 t1 NEXT_HP_STAGE6
		li a2 520
	NEXT_HP_STAGE6:
    li a3 104
    #lw a3 0(a0)
    la a4 camera
    addi a4 a4 8
    call RENDER_ON_CAMERA

    # RENDER CAM IMG
    la a0 camera
	li a1 0
    li a2 0
    li a3 320
    call RENDER

	j AFTER_RENDER_PROCESS

.data
.include "./assets/entrance.s"
.include "./assets/prologue.s"
.include "./assets/entrance_pedra_top.s"
.include "./assets/alucard_hit_weapon.s"
.include "./assets/RichterBelmont.s"
.include "./assets/teste_enemy.s"
.include "./assets/alucard_walk.s"
.include "./assets/alucard_punch.s"
.include "./assets/alucard_idle.s"
.include "./assets/alucard_down.s"
.include "./assets/alucard_sword.s"
.include "./assets/health_bar.s"
.include "./assets/npc.s"
.include "./assets/python.s"
.include "./assets/dialogo1.s"
.include "./assets/dialogo2.s"
.include "./assets/dialogo3.s"



.include "./assets/morcego.s"

# precisa ficar em último -> não sei o porquê :)
.include "./assets/camera.s"
