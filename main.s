#include <xc.inc>

extrn	GLCD_refresh, GLCD_display_on, GLCD_initialize, GLCD_lightPix, XYConv, GLCD_clearPix
extrn Snake_init, keyboardRead, mover ,getApple,Eat_apple, Snake_move, GLCD_ON
global tempX, tempY, lengthCounter, snake_size, start, endgame
psect	udata_acs
	tempX: ds 1
	tempY: ds 1
	d1cont: ds 1
	d2cont: ds 1
	d3cont: ds 1
	lengthCounter: ds 1
        snake_size:	ds 1
	
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
   
    

    
keyBoardStart:
    call keyboardRead
    tstfsz mover, A
    bra gameLoop
    bra keyBoardStart

    


gameLoop:
    call getApple
    call Eat_apple
    call bigDelay
    bra gameLoop
    
    
endgame:
    call GLCD_ON
    call bigDelay
    bra start

bigDelay:
    movlw 0xFF
    movwf d1cont, A
    movwf d2cont, A
    movwf d3cont, A
    call delay2
    return
    
delay1:
    decfsz d1cont, A
    bra delay1
    return
    
delay2:
    call keyboardRead
    decfsz d2cont, A
    bra delay2
    return

delay3:
    call delay2
    decfsz d3cont, A
    bra delay3
    return
    
    end rst