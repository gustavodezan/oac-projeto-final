	la a0 RichterBelmont
	li a1 0
	li a2 96
	li a2 48
	li a3 24

	# a0 -> sprite
    # a1 -> valor a adicionar no vetor
    # a2 -> vetor de frame
	# a3 -> num pixeis em x de cada sprite
	j RENDER_INVERT
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
		li a7 5
		ecall
		li a7 10
		ecall

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
		li a7 10
		ecall

.data
.include "./assets/RichterBelmont.s"
.include "./assets/black_screen.s"