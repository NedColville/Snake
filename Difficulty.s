#include <xc.inc>
extrn keyboardDiff, diffRead, difficulty
global getDifficulty
    
psect diffCode, class=CODE
    
getDifficulty:
    call keyboardDiff
    movlw 0x00
    cpfseq diffRead, A
    bra setDifficulty
    bra getDifficulty
setDifficulty:
    movf diffRead, W, A
    xorlw   0xE7 ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    call diff1
    
    movf diffRead, W, A
    xorlw   0xD7 ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    call diff2
    
    movf diffRead, W, A
    xorlw   0xB7 ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    call diff3
       
    movf diffRead, W, A
    xorlw   0x77 ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    call diff4
    return
diff1:
    movlw 0x80
    movwf difficulty, A
    return
diff2:
    movlw 0x50
    movwf difficulty, A
    return
diff3:
    movlw 0x30
    movwf difficulty, A
    return
diff4:
    movlw 0x10
    movwf difficulty, A
    return


