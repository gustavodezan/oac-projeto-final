.data

.text
	SOUND_HIT:
	li  a7, 31 
	li a0, 72
	li a1, 1500         
    	li a2,120
    	li a3, 100
    	ecall
	j AFTER_SOUND_HIT

	SOUND_HURTED:
	li  a7, 31 
	li a0, 72
	li a1, 225         
    	li a2,81
    	li a3, 127
    	ecall

	j AFTER_SOUND_HURTED