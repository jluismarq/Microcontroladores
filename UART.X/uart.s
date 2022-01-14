    .include "p30F3013.inc"

    .GLOBAL __U1RXInterrupt
    .GLOBAL _dato
    .GLOBAL _drcv
    
;/**@brief ESTA ES LA ISR DEL TIMER 1
; *
; */	
   
__U1RXInterrupt:
	PUSH	W0
    
	MOV	U1RXREG,    W0
	MOV	W0,	    _dato
	MOV	#1,	    W0
	MOV	W0,	    _drcv
	
	BCLR	IFS0,	   #U1RXIF;APAGAR BANDERA DE INTERRUPCION DEL TIMER1
    
	POP	W0
	RETFIE
	



