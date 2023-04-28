	#include <xc.inc>
	
global move_up, move_down, move_left, move_right, cursor, cursorToTail, lightTail
extrn time_inc, snake, snake_size, GLCD_lightPix, XYConv
extrn GLCD_clearPix, tempX, tempY, endgame


psect udata_acs
 length_counter: ds 1
 tempX2: ds 1
 tempY2: ds 1
 cursor: ds 1
 tempCursor: ds 1
psect SnakeMove, class=CODE

;org	0x500

move_down:
    call clearTail
    call preMove
    incf snake+1, A
    movlw 00001000B
    cpfslt snake+1, A
    goto endgame 
    call writeHead
    return
 
move_up:
    call clearTail
    call preMove
    decf snake+1, A
    movlw 00001000B
    cpfslt snake+1, A
    goto endgame
    call writeHead
    return

move_right:
    call clearTail
    call preMove
    incf snake, A
    movlw 00010000B
    cpfslt snake, A
    goto endgame
    call writeHead
    return
move_left:
    call clearTail
    call preMove
    decf snake, A
    movlw 00010000B
    cpfslt snake, A
    goto endgame
    call writeHead
    return
cursorToTail:
    movff snake_size, cursor
    movlw snake
    addwf cursor, A
    decf cursor, A
    decf cursor, A
    return

preMove:
    movff snake_size, length_counter
    call cursorToTail
    incf cursor, A
    incf cursor, A
    incf cursor, A
    incf cursor, A
    
    
moveLoop:
    decf cursor, A
    decf cursor, A
    movff cursor, tempCursor
    decf tempCursor, A
    decf tempCursor, A
    movff tempCursor, FSR0
    movf INDF0, W, A
    movff cursor, FSR0
    movwf INDF0, A
    decf length_counter, A
    
    incf cursor, A
    movff cursor, tempCursor
    decf tempCursor, A
    decf tempCursor, A
    movff tempCursor, FSR0
    movf INDF0, W, A
    movff cursor, FSR0
    movwf INDF0, A
    decf cursor, A
    decfsz length_counter, A 
    bra moveLoop
    return
    

    
clearTail:
    call cursorToTail
    movff cursor, FSR0, A
    movf INDF0, W, A
    movwf tempY, A
    incf cursor, A
    movff cursor, FSR0, A
    movf INDF0, W, A
    movwf tempX, A
    call  XYConv
    call GLCD_clearPix
    return
lightTail:
    call cursorToTail
    movff cursor, FSR0, A
    movf INDF0, W, A
    movwf tempY, A
    incf cursor, A
    movff cursor, FSR0, A
    movf INDF0, W, A
    movwf tempX, A
    call  XYConv
    call GLCD_lightPix
    return
writeHead:
    movf snake, W, A
    movwf tempY, A
    movf snake+1, W, A
    movwf tempX, A
    call XYConv
    call GLCD_lightPix
    return
    


