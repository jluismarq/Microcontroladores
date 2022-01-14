    .include "p30F3013.inc"
    .EQU    RS_LCD,	RF4
    .EQU    RW_LCD,	RF5
    .EQU    E_LCD,	RD8

    .GLOBAL _COMANDO_LCD
    .GLOBAL _DATO_LCD
    .GLOBAL _BF_LCD
    .GLOBAL _INI_LCD_8BITS
; @BRIEF: ESTA RUTINA MANDA COMANDOS AL LCD
; @PARAM: W0, COMANDO A ENVIAR
;    
_COMANDO_LCD:	
    BCLR    PORTF,	#RS_LCD	    ;RS = 0
    NOP
    BCLR    PORTF,	#RW_LCD	    ;RW = 0
    NOP
    BSET    PORTD,	#E_LCD	    ;E = 1
    NOP
    MOV.B   WREG,	PORTB	    ;PORTB(7:0) = W0(7:0)
    NOP
    BCLR    PORTD,	#E_LCD	    ;E = 0
    NOP
    
    RETURN
; @BRIEF: ESTA RUTINA MANDA DATOS AL LCD
; @PARAM: W0, DATO A ENVIAR
;    
_DATO_LCD:
    BSET    PORTF,	#RS_LCD	    ;RS = 1
    NOP
    BCLR    PORTF,	#RW_LCD	    ;RW = 0
    NOP
    BSET    PORTD,	#E_LCD	    ;E = 1
    NOP
    MOV.B   WREG,	PORTB	    ;PORTB(7:0) = W0(7:0)
    NOP
    BCLR    PORTD,	#E_LCD	    ;E = 0
    NOP
    
    RETURN
; @BRIEF: ESTA RUTINA VERIFICA LA BANDERA BUSY FLAG DEL LCD
;    
_BF_LCD:
    PUSH    TRISB
    PUSH    W0
    
    BCLR    PORTF,	#RS_LCD	    ;RS = 0
    NOP
    PUSH    TRISB		    ;STACK(SP++) = TRISB
    NOP
    MOV	    #0X00FF,	W0
    IOR	    TRISB
    NOP
    BSET    PORTF,	#RW_LCD	    ;RW = 1
    NOP
    BSET    PORTD,	#E_LCD	    ;E = 1
    NOP
ESPERA_LCD:
    BTSC    PORTB,	#RB7	    ;POLLING
    GOTO    ESPERA_LCD
    
    BCLR    PORTD,	#E_LCD	    ;E = 0
    NOP
    BCLR    PORTF,	#RW_LCD	    ;RW = 0
    NOP
    
    POP	    W0
    POP	    TRISB
    RETURN
; @BRIEF: ESTA RUTINA INICIALIZA EL LCD EN MODO DE 8 BITS
;    
_INI_LCD_8BITS:
    PUSH    W1
    PUSH    W0
    
    DO #2, INI_CICLO    
	    CALL    _RETARDO_50ms
	    MOV	    #0X30,	W0
	    CALL    _COMANDO_LCD
    INI_CICLO:	NOP

    PUSH    W1
    NOP
    
    CLR	    W1
    
    DO #4, SECOND_CICLO
	    CALL    _BF_LCD
	    CALL    VALORES
	    ADD	    #1,		W1
	    CALL    _COMANDO_LCD
    SECOND_CICLO: NOP
    
    POP	    W1
    POP	    W0
    NOP
    RETURN

VALORES:
    BRA		W1			;PC=PC+W1=BRINCO RELATIVO
    RETLW	#0X38,		W0	
    RETLW	#0X08,		W0	
    RETLW	#0X01,		W0	
    RETLW	#0X06,		W0	
    RETLW	#0X0F,		W0	
    
    
    