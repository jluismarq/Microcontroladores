	.include "p30F3013.inc"
	.EQU	RS_LCD,	    RF4
	.EQU	RW_LCD,	    RF5
	.EQU	E_LCD,	    RD8
	
	.GLOBAL	_COMANDO_LCD
	.GLOBAL	_DATO_LCD
	.GLOBAL	_BF_LCD
	.GLOBAL	_INI_LCD_8BITS
	.GLOBAL _printLCD
	
;   @BRIEF: ESTA RUTINA IMPRIME UNA CADENA EN EL LCD
;   @PARAM: W0, DIRECCIÓN DE LA CADENA A IMPRIMIR
;   @RETURN: NINGUNO
_printLCD:
    PUSH    W0
    PUSH    W1
    
    MOV	    W0,	    W1
IMPRIMIR:
    MOV.B   [W1++], W0
    CP0.B   W0
    BRA	    Z,	    FIN_printLCD
    
    CALL    _BF_LCD
    CALL    _DATO_LCD
    GOTO    IMPRIMIR
    
FIN_printLCD:
    POP	    W0
    POP	    W1
    
    RETURN

;   @BRIEF: ESTA RUTINA MANDA COMANDOS AL LCD
;   @PARAM: W0, COMANDO A ENVIAR
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

;   @BRIEF: ESTA RUTINA MANDA DATOS AL LCD
;   @PARAM: W0, DATO A ENVIAR
;
_DATO_LCD:
    BSET    PORTF,	#RS_LCD	    ;RS = 0
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
	
_BF_LCD:
    PUSH    W0
    
    BCLR    PORTF,	#RS_LCD	    ;RS = 0
    NOP
    PUSH    TRISB		    ;STACK(SP++) = TRISB
    MOV	    #0x00FF,	W0
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
    BCLR    PORTD,	#RW_LCD	    ;RW = 1
    NOP
    POP	    TRISB
    NOP
    
    POP	    W0
    
    RETURN
	
_INI_LCD_8BITS:
    DO	#2, INI_CICLO
	    CALL    _RETARDO_50ms
	    MOV	   #0x30,	W0
	    CALL    _COMANDO_LCD
    INI_CICLO:	    NOP
    
    MOV	    #0x0000,	W1    
    
    DO	#4, INI_CICLO2
	    CALL    _BF_LCD
	    MOV	    W1,	    W0
	    CALL    CONV_COD
	    INC	    W1,	    W1
	    CALL    _COMANDO_LCD
    INI_CICLO2:	    NOP
    
    RETURN
    
CONV_COD:
	BRA	W0		;PC = PC + W0
	RETLW	#0X38,	    W0	
	RETLW	#0X08,	    W0	
	RETLW	#0X01,	    W0	
	RETLW	#0X06,	    W0	
	RETLW	#0X0C,	    W0	
	
	