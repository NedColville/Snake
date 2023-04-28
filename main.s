#include <xc.inc>

extrn	GLCD_refresh, GLCD_display_on, GLCD_initialize, collisionStart, AppleCheck, getDifficulty
extrn Snake_init, keyboardGame, mover ,getApple, Snake_move, GLCD_All_On, diffRead, keyboardDiff
global tempX, tempY, snake_size, rst, endgame, difficulty
psect	udata_acs
	tempX: ds 1
	tempY: ds 1
	d1cont: ds 1
	d2cont: ds 1
	d3cont: ds 1
        snake_size:	ds 1
	difficulty: ds 1
	
psect	code, abs
rst:
    org	0x0
    goto start
    
org	0x100 ; Main code starts here at address 0x100 -- do not place this inside the program loop.  The code below will be separated from the code above!!!

start:
    nop
    movlw 0x06
    movwf snake_size, A
    
    call GLCD_initialize
    nop
    ; Turn on GLCD 
    call GLCD_display_on
    
    call GLCD_refresh
    
    call Snake_init
    movlw 0x00
    movwf mover, A
    call getApple
    call getDifficulty
   
    


    
keyBoardStart:
    call keyboardGame
    tstfsz mover, A
    bra gameLoop
    bra keyBoardStart

    


gameLoop:
    call bigDelay
    call Snake_move
    call collisionStart
    call AppleCheck
    bra gameLoop
    
    
endgame:
    call GLCD_All_On
    call bigDelay
    call bigDelay
    call bigDelay
    call bigDelay
    call bigDelay

    goto start
    

bigDelay:
    movlw 0xFF
    movwf d1cont, A
    movlw 0xFF
    movwf d2cont, A
    movf difficulty,W, A
    movwf d3cont, A
    call delay3
    return
    
delay1:
    decfsz d1cont, A
    bra delay1
    return
    
delay2:
    call keyboardGame
    decfsz d2cont, A
    bra delay2
    return

delay3:
    call delay2
    decfsz d3cont, A
    bra delay3
    return
   
    end rst