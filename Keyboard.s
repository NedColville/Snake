#include <xc.inc>
global keyboardRead, portLow, portHigh, mover, allHigh
psect udata_acs
 portLow: ds 1
 portHigh: ds 1
 mover: ds 1
 KBDel1: ds 1
 outputTemp: ds 1
 allHigh: ds 1
psect keyboard, class=CODE
;org 0x300
keyboardRead:
    movff mover, outputTemp ;temporarily store previous output
    ;movlw 0x00
    movwf mover, A ;set output to zero  
    movlw 0xFF
    movwf allHigh, A ;set comparison check for no press
    banksel PADCFG1
    bsf REPU
    clrf LATE, A
    nop
    nop
    movlw 00001111B ; set bits[0:3] as outputs
    movwf TRISE, A    
    nop
    nop
    movwf LATE, A ;take bits [0:3] as outputs
    movlw 0x20
    movwf KBDel1, A
    call KBDelay ;delay
    
    movf PORTE, W, A ;read off PORTE
    
    
    movwf portLow, A
    movlw 11110000B ;take bits [4-7] as outputs
    movwf TRISE, A
    nop
    nop
    movwf LATE, A ;take bits [4;7] as high
    
    
    movlw 0x20
    movwf KBDel1, A;delay
    call KBDelay
    movf PORTE, W, A ;read off PORTE
    movwf portHigh, A
    
    movf portHigh, W, A
    addwf portLow, W, A ;combine both readings
    cpfsgt allHigh, A ;if no press 0xFF will be recorded - test for that
    movf outputTemp, W, A ;if no press is recorded we store add previous value to w drive
    movwf mover, A ; move contents of W drive to output variable
    
    return
    
KBDelay: ;simple delay function
    decfsz KBDel1, A
    bra KBDelay
    return
    
   
    

    
    
    
    

    


