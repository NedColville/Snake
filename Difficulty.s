#include <xc.inc>
extrn keyboardDiff, diffRead, difficulty
global getDifficulty
    
psect diffCode, class=CODE
 ;Function essentially comprising of a keyboard read and a few skip if not equal to statements in order to load the correct value into difficulty
getDifficulty:
    call keyboardDiff
    movlw 0x00
    cpfseq diffRead, A
    bra setDifficulty
    bra getDifficulty
setDifficulty:
    movf diffRead, W, A
    xorlw   0xE7 ; Skip if measurement not equal to 0xE7, the value associated with the 1 button
    btfsc   STATUS, 2, A ; 
    call diff1
    
    movf diffRead, W, A
    xorlw   0xD7 ; 
    btfsc   STATUS, 2, A ; 
    call diff2
    
    movf diffRead, W, A
    xorlw   0xB7 ;
    btfsc   STATUS, 2, A ;
    call diff3
       
    movf diffRead, W, A
    xorlw   0x77 ; 
    btfsc   STATUS, 2, A ; 
    call diff4
    return
diff1: ;loads a high value into difficulty s.t. the delay takes longer.
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


