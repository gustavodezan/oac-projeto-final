.text
	la a0 prologue
	li a1 0
	li a2 0
	li a3 960

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
	li s0 0xFF000000
	add s0 s0 a1
	RENDER_LOOP:
		lw t5 0(a0)
		sw t5 0(s0)
		addi a0 a0 4
		addi s0 s0 4
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
		add s0 s0 t4
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
	mv s0 a4
	add s0 s0 a1
	li a5 -57 # valor do transparente
	# adicionar procedimento que pula as linhas e colunas de pixeis que estiverem fora da tela

	RENDER_CAM_LOOP:
		lb t5 0(a0)
		beq t5 a5 SKIP_PIXEL_ADD
		sb t5 0(s0)

		SKIP_PIXEL_ADD:
		addi a0 a0 1
		addi s0 s0 1
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
		add s0 s0 t4
		add a0 a0 t0
		li t4 0
		j AFTER_NEW_LINE_CAM

	EXIT_CAM:
		ret

RENDER_INVERT:
	lw t0 0(a0) # x da imagem
 	lw t1 4(a0) # y
	#add t0 t0 a3 # x da imagem - num pixeis em x de cada sprite -> valor para pular no arquivo da imagem
	addi t0 t0 -24
	mul t6 t1 a3 # area
	addi a0 a0 8
	addi a0 a0 24 # pula o final do sprite
	add a0 a0 a2
	li t3 0
	li t4 0
	li s0 0xFF000000
	add s0 s0 a1
	addi s0 s0 24 # offset para invert
	RENDER_LOOP_INVERT:
		lb t5 0(a0)
		sb t5 0(s0)
		addi a0 a0 1
		addi s0 s0 -1
		addi t3 t3 1
		addi t4 t4 1
		bge t4 a3 NEW_LINE_INVERT
	AFTER_NEW_LINE_INVERT:
		blt t3 t6 RENDER_LOOP_INVERT
	END_RENDER_INVERT:
		ret
	NEW_LINE_INVERT:
		li t4 320
		add t4 t4 a3
		add s0 s0 t4
		add a0 a0 t0
		li t4 0
		j AFTER_NEW_LINE_INVERT

	EXIT_INVERT:
		li a7 5
		ecall



IS_ON_CAMERA:


.data
.include "./assets/prologue.s"
.include "./assets/entrance.s"
.include "./assets/RichterBelmont.s"
.include "./assets/teste_enemy.s"
.include "./assets/black_screen.s"
.include "./assets/camera.s"
