#include <xc.inc>
global keyboardGame, portLow, portHigh, mover, validCheck, diffRead, keyboardDiff
extrn up, down, left, right, pause, restart
psect udata_acs
 portLow: ds 1
 portHigh: ds 1
 portTot: ds 1
 mover: ds 1
 KBDel1: ds 1
 outputTemp: ds 1
 allHigh: ds 1
 validCheck: ds 1
 diffRead: ds 1
psect keyboard, class=CODE
;org 0x300
keyboardRead:;function for reading off the keyboard
    movff mover, outputTemp ;temporarily store previous output
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
    movwf portTot, A
    return
    
    keyboardGame:
    call keyboardRead
    ;INPUT SANITISATION - Invalid inputs arise from 
    ;Need to reject an input and take previous one if invalid input (such as no press)
    
    movlw 0x0
    movwf validCheck, A
    movf portTot, W, A
    xorlw   up  ;Below are bits of code similar to this - these are essentially skip if not equal to statements
    btfsc   STATUS, 2, A ; We load the measured value and if it matches a valid value (up in this case) we increase the valid checker
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   down  ; Same as before
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   left  ; 
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   right ;
    btfsc   STATUS, 2, A ;
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   pause  ; 
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   restart  ; 
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movff portTot, mover, A
    movf validCheck, W, A
    xorlw   0x00  ; This is another skip if not equal to - however we are skipping if valid check is not equal to zero
    ;i.e. skipping if a valid entry has been entered and has been subsequently incremented
    btfsc   STATUS, 2, A ; 
    movff outputTemp, mover, A ;if validCheck has not been incremented we have received an invalid input - meaning we take the value from the last cycle
    
    
    
    
    return
keyboardDiff: ;exactly the same function containing validity checks but for the difficulty selection
    call keyboardRead
    ;INPUT SANITISATION - Invalid inputs arise from key bouncing
    ;Need to reject an input and take previous one if invalid input (such as no press)

    
    movlw 0x0
    movwf validCheck, A
    movf portTot, W, A
    xorlw   0xE7  ;
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   0xD7  ; 
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   0xB7  ; 
    btfsc   STATUS, 2, A ; 
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   0x77 ; 
    btfsc   STATUS, 2, A ;
    incf validCheck, A
    
    movff portTot, diffRead, A
    movf validCheck, W, A
    xorlw   0x00  ; 
    btfsc   STATUS, 2, A ; 
    call invalidDiff   
    
    
    
    return
invalidDiff:
    movlw 0x00
    movwf diffRead, A
    return
KBDelay: ;simple delay function
    decfsz KBDel1, A
    bra KBDelay
    return
    
   
    

    
    
    
    

    


