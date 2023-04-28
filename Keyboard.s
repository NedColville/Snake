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
keyboardRead:
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
    xorlw   up  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   down  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   left  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   right ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   pause  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   restart  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movff portTot, mover, A
    movf validCheck, W, A
    xorlw   0x00  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    movff outputTemp, mover, A
    
    
    
    
    return
keyboardDiff:
    call keyboardRead
    ;INPUT SANITISATION - Invalid inputs arise from 
    ;Need to reject an input and take previous one if invalid input (such as no press)
    
    movlw 0x0
    movwf validCheck, A
    movf portTot, W, A
    xorlw   0xE7  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   0xD7  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   0xB7  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movf portTot, W, A
    xorlw   0x77 ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    incf validCheck, A
    
    movff portTot, diffRead, A
    movf validCheck, W, A
    xorlw   0x00  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
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
    
   
    

    
    
    
    

    


