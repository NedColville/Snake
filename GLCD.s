#include <xc.inc>
global GLCD_refresh,GLCD_display_on, GLCD_initialize, GLCD_lightPix
global XYConv, GLCD_clearPix, GLCD_All_On, GLCD_lightApple
extrn tempY, tempX
    

psect	udata_acs



reg8: ds 1
tempY2: ds 1
    
   
delay_cntr: ds 1
Y_addr: ds 1
X_addr: ds 1    
    
CS1 equ 0
CS2 equ 1
DI equ 2
RorW equ 3
EN equ 4
RST equ 5
 
psect glcd, class=CODE
;File containing all GLCD functions
;org 0x500


    

GLCD_initialize: ;sets ctrl as an input and clears data bus
    clrf  TRISB, A ; CTRL lines
    clrf  LATB, A  ; data bus
    
GLCD_reset: ;sets reset pin
    bcf LATB, RST, A; reset
    nop
    nop
    nop
    nop
    bsf LATB, RST, A; clear reset
    return
    
;============
GLCD_refresh: ;function which writes 0s to the entire GLCD
;------------   
    call GLCD_pickPageB
    movlw 0x00
    call GLCD_sety
    movlw 0x00
    call GLCD_setx

; write data sequentially to the GLCD
h_loop:    
    call Write_h
    incf X_addr, F, A    
    movf X_addr, W, A
    call GLCD_pickPageB
    call GLCD_setx
    tstfsz X_addr, A
    bra h_loop
    call setTopLeft
    return
    
Write_h:
    call GLCD_pickPageL
    call Write_half_h
    call GLCD_pickPageR
    call Write_half_h 
    return
    
Write_half_h:
    movlw 0x0 
    call GLCD_write_data
    incf Y_addr, F, A
    movlw 0x3f
    andwf Y_addr, F, A
    tstfsz Y_addr, A
    bra Write_half_h
    return
    
GLCD_All_On: ;function which writes all 1s to the GLCD
    call GLCD_pickPageB
    movlw 0x00
    call GLCD_sety
    movlw 0x00
    call GLCD_setx
    
h_loop2:    
    call Write_h2
    incf X_addr, F, A    
    movf X_addr, W, A
    call GLCD_pickPageB
    call GLCD_setx
    tstfsz X_addr, A
    bra h_loop2
    call setTopLeft
    return
    
Write_h2:
    call GLCD_pickPageL
    call Write_half_h2
    call GLCD_pickPageR
    call Write_half_h2
    return
Write_half_h2:
    movlw 0xFF
    call GLCD_write_data
    incf Y_addr, F, A
    movlw 0x3f
    andwf Y_addr, F, A
    tstfsz Y_addr, A
    bra Write_half_h2
    return   
    

    

GLCD_pickPageL: ;functions setting chip select pins to pick a page
    bcf LATB, CS1, A ;CS0=0
    bsf LATB, CS2, A ;CS1=1
    return
GLCD_pickPageR:
    bsf LATB, CS1, A ;CS0=1
    bcf LATB, CS2, A ;CS1=0
    return
GLCD_pickPageB:
    bcf LATB, CS1, A ;CS0=0
    bcf LATB, CS2, A ;CS1=0
    return    
    
;GLCD writing instruction interface
GLCD_display_on: ;Turns on GLCD
    call GLCD_pickPageB
    movlw 00111111B
    bra write_and_wait_i
GLCD_display_off: ;Turns off GLCD
    call GLCD_pickPageB
    movlw 00111110B
    bra write_and_wait_i
GLCD_sety: ;moves info from [0:5] of W reg to set y address
    andlw 00111111B 
    movwf Y_addr, A
    iorlw 01000000B    
    call write_and_wait_i
GLCD_setx: ;moves info from [0:2] of W reg to set x address
    andlw 00000111B
    movwf X_addr, A
    iorlw 10111000B    
    call write_and_wait_i
write_and_wait_i:    
    call Write_instruction
    call GLCD_Wait_ready
    return    

GLCD_write_data:
    call Write_data
    call GLCD_Wait_ready  
    return
    
GLCD_Wait_ready:
    call Read_status ;reads status of GLCD
    andlw 10010000B ; only takes important parts
    bnz GLCD_Wait_ready ; if non zero we loop back
    return        

;GLCD Write cycle function
Write_instruction:
    bcf LATB, DI, A ;sets D/I lo
    bra write_cycle
Write_data:
    bsf LATB, DI, A ;sets D/ hi
    bra write_cycle
write_cycle: ;moves W drive to PORTD
    bcf LATB, RorW, A ;set low to write    
    clrf TRISD, A ;sets PORTD to outputs
    movwf LATD, A ;sends command in W drive to PORTB
    ; pulse enable bit LCD_E for 500ns
    movlw 0x20
    movwf delay_cntr, A
    call delay
    bsf	LATB, EN, A	    ; Take enable high
    movlw 0x20
    movwf delay_cntr, A
    call delay
    bcf	LATB, EN, A	    ; Writes data to LCD
    return
    
;GLCD Read cycle function
Read_status:    
    bcf LATB, DI, A ;sets D/I lo
    bra read_cycle
Read_data:
    bsf LATB, DI, A ;sets D/ hi
    bra read_cycle
read_cycle:
    bsf LATB, RorW, A ;set high to read   
    setf TRISD, A ;sets PORTD to input
    movlw 0x20
    movwf delay_cntr, A
    call delay
    bsf LATB, EN, A ;pulse enable
    movlw 0x20
    movwf delay_cntr, A
    call delay
    movf PORTD, W, A ;save status bits
    bcf LATB, EN, A 
    return
    
    
    setTopLeft:
    movlw 0x00
    call GLCD_sety
    movlw 0x00
    call GLCD_setx
    call GLCD_pickPageL
    return

GLCD_lightPix: ;function to be called which write 1s to 8 lines in a row, lighting an 8x8 'pixel of pixels'
    movlw 00001000B ;want to stop at 9
    movwf reg8, A
    call pixLoopLight
    return
pixLoopLight:
    movlw 0xFF
    call GLCD_write_data
    decfsz reg8, A
    bra pixLoopLight
    return
GLCD_clearPix: ;function to be called which writes 0s to 8 lines in a row
    movlw 00001000B
    movwf reg8, A
    call pixLoopClear
    return
pixLoopClear:
    movlw 0x00
    call GLCD_write_data
    decfsz reg8, A
    bra pixLoopClear
    return
    
XYConv: ;Takes XY value from W drive and moves cursor to that position
    movf tempY, W, A ;saves Y temporarily
    andlw 00001111B ;input sanitisation
    movwf tempY, A 
    btfss tempY, 3 , A;if less than 7 pick left page
    call GLCD_pickPageL;
    btfsc tempY, 3, A ; if greater than 7 pick right page
    call GLCD_pickPageR
    andlw 00000111B 
    movwf tempY2, A
    movlw 00001000B
    mulwf tempY, A
    movf PRODL, W, A
    call GLCD_sety
    
   
    
    
    movf tempX, W, A
    andlw 0111B
    movwf tempX, A
    call GLCD_setx
    return



GLCD_lightApple: ;special pixel art for the apples
    movlw 0xFF
    call GLCD_write_data
    movlw 0xFF
    call GLCD_write_data
    movlw 0xC3
    call GLCD_write_data
    movlw 0xC3
    call GLCD_write_data
    movlw 0xC3
    call GLCD_write_data
    movlw 0xC3
    call GLCD_write_data
    movlw 0xFF
    call GLCD_write_data
    movlw 0xFF
    call GLCD_write_data
    return


delay: ;delay for 250ns*val in
    decfsz delay_cntr, A
    bra delay
    return
    
end
