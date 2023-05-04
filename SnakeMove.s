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
;All functions below are very similar for respective movements of the snake. Comments for move_down can be applied to the rest
move_down:
    call clearTail;remove tail before moving
    call preMove
    incf snake+1, A;increase vertical co-ord of head for down movement
    movlw 00001000B
    cpfslt snake+1, A; compare if new vertical co-ord of head is located past the wall
    goto endgame ;if so - end the game
    call writeHead;if not - write this new pixel
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
cursorToTail:;useful little function which loads the address of the tail into cursor
    movff snake_size, cursor
    movlw snake
    addwf cursor, A
    decf cursor, A
    decf cursor, A
    return

preMove:;main function for changing VALUES of the body of the snake in memory
    ;initialising variables before main operations
    movff snake_size, length_counter
    call cursorToTail
    incf cursor, A
    incf cursor, A
    incf cursor, A
    incf cursor, A
    
    
moveLoop:
    decf cursor, A
    decf cursor, A; decrease cursor to previous horz address
    movff cursor, tempCursor;move to temporary cursor variable
    decf tempCursor, A;decrease to previous horz address
    decf tempCursor, A
    movff tempCursor, FSR0;load into fsr0 for indirect addressing
    movf INDF0, W, A;load horz co-ord stored in the addres stored in tempcursor
    movff cursor, FSR0;move cursor to fsr0
    movwf INDF0, A;move w reg to [cursor]
    decf length_counter, A
    
    incf cursor, A;increase cursor once to access vertical co-ords
    movff cursor, tempCursor;similar indirect addressing and swapping co-ords as for horz
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
    

    
clearTail:;function for pointing cursor to tail and loading co-ords to clear the pixel on glcd
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
lightTail:;similar function to light the tail once an apple is eaten
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
writeHead:;function which loads xy co-ords of new position of head and lights pixel on GLCD
    movf snake, W, A
    movwf tempY, A
    movf snake+1, W, A
    movwf tempX, A
    call XYConv
    call GLCD_lightPix
    return
    


