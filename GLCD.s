#include <xc.inc>
global GLCD_display_on, GLCD_display_off,GLCD_output, GLCD_sety, GLCD_setx, set_IO, GLCD_pickPageL, send_I, send_D

psect	udata_acs
Y_addr equ 0x10
X_addr equ 0x11
temp_X: ds 1
temp_Y: ds 1
   
    
    
CS1 equ 0
CS2 equ 1
DI equ 2
RorW equ 3
EN equ 4
RST equ 5
psect glcd, class=CODE
;psect code
    org 0x500


send_I:
    bcf LATB, DI ;sets D/I lo
    bra GLCD_output
    
send_D:
    bsf LATB, DI ;sets D/ hi
    bra GLCD_output
set_IO:
    clrf  TRISB
    clrf  LATB
    bcf LATB, RST;
    nop
    nop
    nop
    nop
    
    bsf LATB, RST; Toggle reset
    return
    

GLCD_display_on: ;Turns on GLCD
    movlw 00111111B
    call GLCD_pickPageB
    bra send_I
GLCD_display_off: ;Turns off GLCD
    movlw 00111110B
    call GLCD_pickPageB
    bra send_I
GLCD_pickPageL:
    bcf LATB, CS1 ;CS0=0
    bsf LATB, CS2 ;CS1=1
    return
GLCD_pickPageR:
    bsf LATB, CS1 ;CS0=1
    bcf LATB, CS2 ;CS1=0
    return
GLCD_pickPageB:
    bcf LATB, CS1 ;CS0=0
    bcf LATB, CS2 ;CS1=0
    return
    
GLCD_output: ;moves W drive to PORTD
    bcf LATB, RorW ;set low to write
    
    clrf TRISD ;sets PORTD to outputs
    movwf LATD ;sends command in W drive to PORTB
    call GLCD_Enable ;pulses enable
      
    btfss LATB, DI ;if sending data...
    bra GLCD_Wait ;if sending info go straight to wait  
    incf Y_addr
    movlw 01000000B
    cpfslt Y_addr
    call checkPos
    
   
    

       
GLCD_Wait:
    call GLCD_read_busy ;reads status of GLCD
    andlw 10010000B ; only takes important parts
    bnz GLCD_Wait ; if non zero we loop back
    return
    
GLCD_read_busy:
    bcf LATB, DI ;set lo to for instruction
GLCD_read_data:
    bsf LATB, RorW
GLCD_input:
    bsf LATB, RorW ;set hi to read
    setf TRISD ; set portD inputs
    movlw 0x80
    movwf 0x05
    call delay
    bsf LATB, EN ;pulse enable
    movlw 0x80
    movwf 0x05
    call delay
    movf PORTD, W ;save status bits
    bcf LATB, EN 
    return
GLCD_sety: ;moves info from [0:5] of W reg to set y address
    andlw 00111111B 
    movwf Y_addr
    iorlw 01000000B    
    bra send_I

GLCD_setx: ;moves info from [0:2] of W reg to set x address
    andlw 00000111B
    movwf X_addr
    iorlw 10111000B    
    bra send_I


checkPos:
    btfss PORTB, CS1
    bra swapPage
    btfss PORTB, CS2
    bra dropLine
    
    return
swapPage:
    call GLCD_sety
    bra GLCD_pickPageR
    
dropLine:
    call GLCD_pickPageL
    incf X_addr
    movlw X_addr
    call GLCD_setx
    movf Y_addr, W
    call GLCD_sety
    return
   
    
    
GLCD_Enable:	    ; pulse enable bit LCD_E for 500ns
	movlw 0x80
	movwf 0x05
	call delay
	bsf	LATB, EN, A	    ; Take enable high
	movlw 0x80
	movwf 0x05
	call delay
	bcf	LATB, EN, A	    ; Writes data to LCD
	return


    



delay: ;delay for 250ns*val in 0x01
    decfsz 0x05, A
    bra delay
    return


    
    
    
    
    
    
    
 end   
    




