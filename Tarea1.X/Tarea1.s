;/**@brief Tarea 1: Hacer un programa en el ensamblador del DSPIC para implementar
;una calculadora con las operaciones de suma, resta, multiplicacion y division.
;Las operaciones se deben seleccionar usando
;las terminales RD8 y RD9 del puerto D de acuerdo a la tabla 1.
; *   -------------------------------------------------------------------------
; *  |  RD9  |  RD8 |	Operacion	             |   Significado          |
; *  |-------|------|--------------------------------|------------------------|
; *  |   0   |   0  |	Resta de constante	     | PORTB = PORTF(5:2) - K |
; *  |   0   |   1  |	Suma de constante	     | PORTB = PORTF(5:2) + K |
; *  |   1   |   0  |	Multiplicacion por constante | PORTB = PORTF(5:2) * K |
; *  |   1   |   1  |	Division por constante	     | PORTB = PORTF(5:2) / K |
; *   -------------------------------------------------------------------------
; * @device: DSPIC30F3013
; * @oscilator: FRC, 7.3728MHz
; * @Trabajo: FRC/4, 1.8432MHz
; */
        .equ __30F3013, 1
        .include "p30F3013.inc"
;******************************************************************************
; BITS DE CONFIGURACI?N
;******************************************************************************
;..............................................................................
;SE DESACTIVA EL CLOCK SWITCHING Y EL FAIL-SAFE CLOCK MONITOR (FSCM) Y SE 
;ACTIVA EL OSCILADOR INTERNO (FAST RC) PARA TRABAJAR
;FSCM: PERMITE AL DISPOSITIVO CONTINUAR OPERANDO AUN CUANDO OCURRA UNA FALLA 
;EN EL OSCILADOR. CUANDO OCURRE UNA FALLA EN EL OSCILADOR SE GENERA UNA TRAMPA
;Y SE CAMBIA EL RELOJ AL OSCILADOR FRC  
;..............................................................................
        config __FOSC, CSW_FSCM_OFF & FRC   
;..............................................................................
;SE DESACTIVA EL WATCHDOG
;..............................................................................
        config __FWDT, WDT_OFF 
;..............................................................................
;SE ACTIVA EL POWER ON RESET (POR), BROWN OUT RESET (BOR), POWER UP TIMER (PWRT)
;Y EL MASTER CLEAR (MCLR)
;POR: AL MOMENTO DE ALIMENTAR EL DSPIC OCURRE UN RESET CUANDO EL VOLTAJE DE 
;ALIMENTACI?N ALCANZA UN VOLTAJE DE UMBRAL (VPOR), EL CUAL ES 1.85V
;BOR: ESTE MODULO GENERA UN RESET CUANDO EL VOLTAJE DE ALIMENTACI?N DECAE
;POR DEBAJO DE UN CIERTO UMBRAL ESTABLECIDO (2.7V) 
;PWRT: MANTIENE AL DSPIC EN RESET POR UN CIERTO TIEMPO ESTABLECIDO, ESTO AYUDA
;A ASEGURAR QUE EL VOLTAJE DE ALIMENTACI?N SE HA ESTABILIZADO (16ms) 
;..............................................................................
        config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
;..............................................................................
;SE DESACTIVA EL C?DIGO DE PROTECCI?N
;..............................................................................
   	config __FGS, CODE_PROT_OFF & GWRP_OFF      

;******************************************************************************
; SECCI?N DE DECLARACI?N DE CONSTANTES CON LA DIRECTIVA .EQU (= DEFINE EN C)
;******************************************************************************
        .equ MUESTRAS, 64         ;N?MERO DE MUESTRAS

;******************************************************************************
; DECLARACIONES GLOBALES
;******************************************************************************
;..............................................................................
;PROPORCIONA ALCANCE GLOBAL A LA FUNCI?N _wreg_init, ESTO PERMITE LLAMAR A LA 
;FUNCI?N DESDE UN OTRO PROGRAMA EN ENSAMBLADOR O EN C COLOCANDO LA DECLARACI?N
;"EXTERN"
;..............................................................................
        .global _wreg_init     
;..............................................................................
;ETIQUETA DE LA PRIMER LINEA DE C?DIGO
;..............................................................................
        .global __reset          
;..............................................................................
;DECLARACI?N DE LA ISR DEL TIMER 1 COMO GLOBAL
;..............................................................................
        .global __T1Interrupt    

;******************************************************************************
;CONSTANTES ALMACENADAS EN EL ESPACIO DE LA MEMORIA DE PROGRAMA
;******************************************************************************
        .section .myconstbuffer, code
;..............................................................................
;ALINEA LA SIGUIENTE PALABRA ALMACENADA EN LA MEMORIA 
;DE PROGRAMA A UNA DIRECCION MULTIPLO DE 2
;..............................................................................
        .palign 2                

ps_coeff:
        .hword   0x0002, 0x0003, 0x0005, 0x000A

;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO X DE LA MEMORIA DE DATOS
;******************************************************************************
         .section .xbss, bss, xmemory

x_input: .space 2*MUESTRAS        ;RESERVANDO ESPACIO (EN BYTES) A LA VARIABLE

;******************************************************************************
;VARIABLES NO INICIALIZADAS EN EL ESPACIO Y DE LA MEMORIA DE DATOS
;******************************************************************************

          .section .ybss, bss, ymemory

y_input:  .space 2*MUESTRAS       ;RESERVANDO ESPACIO (EN BYTES) A LA VARIABLE
;******************************************************************************
;VARIABLES NO INICIALIZADAS LA MEMORIA DE DATOS CERCANA (NEAR), LOCALIZADA
;EN LOS PRIMEROS 8KB DE RAM
;******************************************************************************
          .section .nbss, bss, near

var1:     .space 2               ;LA VARIABLE VAR1 RESERVA 1 WORD DE ESPACIO

;******************************************************************************
;SECCION DE CODIGO EN LA MEMORIA DE PROGRAMA
;******************************************************************************
.text					;INICIO DE LA SECCION DE CODIGO

__reset:
        MOV	#__SP_init, 	W15	;INICIALIZA EL STACK POINTER

        MOV 	#__SPLIM_init, 	W0     	;INICIALIZA EL REGISTRO STACK POINTER LIMIT 
        MOV 	W0, 		SPLIM

        NOP                       	;UN NOP DESPUES DE LA INICIALIZACION DE SPLIM

        CALL 	_WREG_INIT          	;SE LLAMA A LA RUTINA DE INICIALIZACION DE REGISTROS
                                  	;OPCIONALMENTE USAR RCALL EN LUGAR DE CALL
        CALL    INI_PERIFERICOS
CICLO:
        NOP
	MOV	PORTF,		W0	;W0=PORTF
	NOP
	AND	#0X03C,		W0	;WO = WO & 0X003C
	
	LSR	W0,		#2,	W0
	
	BTSS	PORTD,		#RD9
	GOTO	SUMA_RESTA
	
	GOTO	MULTIPLICACION_DIVISION
	
	NOP
        GOTO    CICLO 
	
SUMA_RESTA:
	BTSS	PORTD,		#RD8
	GOTO	RESTAR_CONST
	
	GOTO	SUMAR_CONST
	
	NOP
	GOTO	CICLO
	
MULTIPLICACION_DIVISION:
	BTSS	PORTD,		#RD8
	GOTO	MULTIPLICAR_CONST
	
	GOTO	DIVIDIR_CONST
	
	NOP
	GOTO	CICLO

SUMAR_CONST:
	ADD	w0,		#5,	w0
	
	MOV	w0,		PORTB
	NOP
	GOTO	CICLO
	
RESTAR_CONST:
	SUB	W0,		#5,	w0
	
	MOV	w0,		PORTB
	NOP
	GOTO	CICLO
	
MULTIPLICAR_CONST:
	MUL.UU	w0,		#5,	w0
	
	MOV	w0,		PORTB
	NOP
	GOTO	CICLO
	
DIVIDIR_CONST:
	MOV	#5,		W4
	MOV	w0,		w3
	NOP
	REPEAT	#17
	DIV.U	W3,		W4
	NOP
	
	MOV	w0,		PORTB
	NOP
	GOTO	CICLO
	
;/**@brief ESTA RUTINA INICIALIZA LOS PUESTOS F Y B DEL DSC
; */
INI_PERIFERICOS:
	CLR	PORTD
	NOP
	CLR	LATD
	NOP
	SETM	TRISD
	NOP
    
	CLR	PORTF
	NOP
	CLR	LATF
	NOP
	SETM	TRISF
	NOP
	
	CLR	PORTB
	NOP
	CLR	LATB
	NOP
	CLR	TRISB
	NOP
	SETM	ADPCFG

        RETURN

;/**@brief ESTA RUTINA INICIALIZA LOS REGISTROS Wn A 0X0000
; */
_WREG_INIT:
        CLR 	W0
        MOV 	W0, 				W14
        REPEAT 	#12
        MOV 	W0, 				[++W14]
        CLR 	W14
        RETURN

;/**@brief ISR (INTERRUPT SERVICE ROUTINE) DEL TIMER 1
; * SE USA PUSH.S PARA GUARDAR LOS REGISTROS W0, W1, W2, W3, 
; * C, Z, N Y DC EN LOS REGISTROS SOMBRA
; */
__T1Interrupt:
        PUSH.S 


        BCLR IFS0, #T1IF           ;SE LIMPIA LA BANDERA DE INTERRUPCION DEL TIMER 1

        POP.S

        RETFIE                     ;REGRESO DE LA ISR


.END                               ;TERMINACION DEL CODIGO DE PROGRAMA EN ESTE ARCHIVO


