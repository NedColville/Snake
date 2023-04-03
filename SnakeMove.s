	#include <xc.inc>
	
global move_up, move_down, move_left, move_right, headtailcheck
extrn time_inc, snake, Eat_apple, snake_size, GLCD_lightPix, XYConv
extrn GLCD_clearPix, tempX, tempY, tailmemcount
extrn offset, headtailcheck, tailtemp, offset2
extrn	tailx1, tailx2, taily1, taily2, tailtrack
	
psect SnakeMove, class=CODE

;org	0x500

	
move_down:
    ; check if snake+snake_size-2-tailmemcount = snake

    movf    tailmemcount, W, A

    subwf   snake_size, W, A

    movwf   headtailcheck, A

    decf    headtailcheck, A        ; headtailcheck = snake_size-tailmemcount-2

    decf    headtailcheck, A

    movf    headtailcheck, W, A

    bz      reset_countdown ; Branch to reset_count if snake loc.

                        ; and headtailcheck are equal

   

    continue_down:        

	;call    clearTail                        

   

    ; After cleared tail from GLCD, locate new tail positions

    ;movf    tail_xloc, W, A

    ;subwf  

    

   ; move old head position to where old tail was

   ; IN MEMORY NOT LOCATION - which stays same

 

    ; Calculate the offset using the values pointed to by snake_size and tailmemcount

    movlw 0x02                  ; Load the value of snake_size into the W register

    subwf snake_size, W, A        ; Subtract 2 from snake_size

    movwf  offset, A                         ; just use offset as temp, will be defined properly in 2 lines

    movf  tailmemcount, W, A

    subwf offset, W  , A          ; Subtract tailmemcount from (snake_size-2)

    movwf offset, A            ; Store the result in the offset variable

 

    ; Store the x coordinate at the memory location (snake + offset)

    movlw   snake

    addwf   offset, W, A

    movwf   FSR0, A

    movf    snake, W, A

    movwf   INDF0, A

 

    ; Store the y coordinate at the memory location (snake + 1 + offset)

    movlw   snake + 1

    addwf   offset, W, A

    movwf   FSR0, A

    movf    snake + 1, W, A

    movwf   INDF0, A

    
    DECF    snake+1, A		    ; decrement y value of head to move down
    
    INCF    tailmemcount, A
    INCF    tailmemcount, A    ; increase twice as have both x and y vals to consider
    
    call writeHead
    
    ; After cleared tail from GLCD, locate new tail x, y memory locations

    decf    tailtrack, A
    decf    tailtrack, A
    
    movlw   0x01
    subwf   tailtrack, W, A
    bz      reset_taildown ; Branch to reset_count if snake loc.
			     ; and headtailcheck are equal
			     
    continue_d:
    movf    tailtrack, W, A
    movwf   taily1, A
    movf    tailtrack, W, A
    movwf   tailx1, A
    incf    tailx1, A
     
    incf    tailmemcount, A
    incf    tailmemcount, A
    
    ; Increment time
    INCF time_inc, F, A
   
    ; HERE I WOULD GOTO GLCD FUNCTION WHICH WILL DISPLAY NEW COORDS
    ; AND HAVE THE CALL SNAKE_MOVE FUNCTION FROM THERE
    return

    
move_up:
   ; check if snake+snake_size-2-tailmemcount = snake

    movf    tailmemcount, W, A

    subwf   snake_size, W, A

    movwf   headtailcheck, A

    decf    headtailcheck, A        ; headtailcheck = snake_size-tailmemcount-2

    decf    headtailcheck, A

    movf    headtailcheck, W, A

    bz      reset_countup ; Branch to reset_count if snake loc.

                        ; and headtailcheck are equal

   

    continue_up:        

    call    clearTail                        

   

    ; After cleared tail from GLCD, locate new tail positions

    ;movf    tail_xloc, W, A

    ;subwf  

    

   ; move old head position to where old tail was

   ; IN MEMORY NOT LOCATION - which stays same

 

    ; Calculate the offset using the values pointed to by snake_size and tailmemcount

    movlw 0x02                   ; Load the value of snake_size into the W register

    subwf snake_size, W, A        ; Subtract 2 from snake_size

    movwf  offset, A                         ; just use offset as temp, will be defined properly in 2 lines

    movf  tailmemcount, W, A

    subwf offset, W, A            ; Subtract tailmemcount from (snake_size-2)

    movwf offset, A            ; Store the result in the offset variable

 

    ; Store the x coordinate at the memory location (snake + offset)

    movlw   snake

    addwf   offset, W, A

    movwf   FSR0, A

    movf    snake, W, A

    movwf   INDF0, A

 

    ; Store the y coordinate at the memory location (snake + 1 + offset)

    movlw   snake + 1

    addwf   offset, W, A

    movwf   FSR0, A

    movf    snake + 1, W, A

    movwf   INDF0, A

    
    INCF    snake+1, A		    ; increment y value of head to move up
    call writeHead
    
    ; After cleared tail from GLCD, locate new tail x, y memory locations

    decf    tailtrack, A
    decf    tailtrack, A
    
    movlw   0x01
    subwf   tailtrack, W, A
    bz      reset_tailup ; Branch to reset_count if snake loc.
			     ; and headtailcheck are equal
			     
    continue_u:
    movf    tailtrack, W, A
    movwf   taily1, A
    movf    tailtrack, W, A
    movwf   tailx1, A
    incf    tailx1, A
     
    incf    tailmemcount, A
    incf    tailmemcount, A
    
    ; Increment time
    INCF time_inc, F, A
   
    ; HERE I WOULD GOTO GLCD FUNCTION WHICH WILL DISPLAY NEW COORDS
    ; AND HAVE THE CALL SNAKE_MOVE FUNCTION FROM THERE
    return
 
    
move_left:
   ; check if snake+snake_size-2-tailmemcount = snake

    movf    tailmemcount, W, A

    subwf   snake_size, W, A

    movwf   headtailcheck, A

    decf    headtailcheck, A        ; headtailcheck = snake_size-tailmemcount-2

    decf    headtailcheck, A

    movf    headtailcheck, W, A

    bz      reset_countleft ; Branch to reset_count if snake loc.

                        ; and headtailcheck are equal

   

    continue_left:        

    call    clearTail                        

   

    ; After cleared tail from GLCD, locate new tail positions

    ;movf    tail_xloc, W, A

    ;subwf  

    

   ; move old head position to where old tail was

   ; IN MEMORY NOT LOCATION - which stays same

 

    ; Calculate the offset using the values pointed to by snake_size and tailmemcount

    movlw 0x02                   ; Load the value of snake_size into the W register

    subwf snake_size, W, A        ; Subtract 2 from snake_size

    movwf  offset, A                         ; just use offset as temp, will be defined properly in 2 lines

    movf  tailmemcount, W, A

    subwf offset, W, A            ; Subtract tailmemcount from (snake_size-2)

    movwf offset, A            ; Store the result in the offset variable

 

    ; Store the x coordinate at the memory location (snake + offset)

    movlw   snake

    addwf   offset, W, A

    movwf   FSR0

    movf    snake, W, A

    movwf   INDF0

 

    ; Store the y coordinate at the memory location (snake + 1 + offset)

    movlw   snake + 1

    addwf   offset, W, A

    movwf   FSR0

    movf    snake + 1, W, A

    movwf   INDF0
    
    DECF    snake, A		    ; decrement x value of head to move left
    call writeHead
    
    ; After cleared tail from GLCD, locate new tail x, y memory locations

    decf    tailtrack, A
    decf    tailtrack, A
    
    movlw   0x01
    subwf   tailtrack, W, A
    bz      reset_tailleft ; Branch to reset_count if snake loc.
			     ; and headtailcheck are equal
			     
    continue_l:
    movf    tailtrack, W, A
    movwf   taily1, A
    movf    tailtrack, W, A
    movwf   tailx1, A
    incf    tailx1, A
     
    incf    tailmemcount, A
    incf    tailmemcount, A
    
    ; Increment time
    INCF time_inc, F, A
   
    ; HERE I WOULD GOTO GLCD FUNCTION WHICH WILL DISPLAY NEW COORDS
    ; AND HAVE THE CALL SNAKE_MOVE FUNCTION FROM THERE
    return
    

move_right: 
    
   ; check if snake+snake_size-2-tailmemcount = snake

    movf    tailmemcount, W, A

    subwf   snake_size, W, A

    movwf   headtailcheck, A

    decf    headtailcheck, A        ; headtailcheck = snake_size-tailmemcount-2

    decf    headtailcheck, A

    movf    headtailcheck, W, A

    bz      reset_countright ; Branch to reset_count if snake loc.

                        ; and headtailcheck are equal

   

    continue_right:        

    call    clearTail                       

   ; move old head position to where old tail was

   ; IN MEMORY NOT LOCATION - which stays same

 

    ; Calculate the offset using the values pointed to by snake_size and tailmemcount

    movlw 0x02                   ; Load the value of snake_size into the W register

    subwf snake_size, W, A        ; Subtract 2 from snake_size

    movwf  offset, A              ; just use offset as temp, will be defined properly in 2 lines

    movf  tailmemcount, W, A

    subwf offset, W, A            ; Subtract tailmemcount from (snake_size-2)

    movwf offset, A            ; Store the result in the offset variable

    

    ; Store the x coordinate at the memory location (snake + offset)

    movlw   snake

    addwf   offset, W, A

    movwf   FSR0

    movf    snake, W, A

    movwf   INDF0

 

    ; Store the y coordinate at the memory location (snake + 1 + offset)

    movlw   snake + 1

    addwf   offset, W, A

    movwf   FSR0

    movf    snake + 1, W, A

    movwf   INDF0
    
    INCF    snake, A		    ; increment x value of head to move right
    call writeHead
    
    ; After cleared tail from GLCD, locate new tail x, y memory locations

    
    ;movf    offset, W, A
   ; movwf   offset2, A	    ; store spare offset to be used in second part
    
    ;movlw   snake
   ; addwf   offset, A
    ;movf    tailmemcount, W, A
    ;subwf   offset, A
    ;movf    offset, W, A
    ;movwf   taily1, A
    
    ;movlw   snake
   ; addwf   offset2, A
   ; movf    tailmemcount, W, A
   ; subwf   offset2, A
   ; incf    offset2, A
   ; movf    offset2, W, A
    ;movwf   tailx1, A
    

    decf    tailtrack, A
    decf    tailtrack, A
    
    movlw   0x01
    subwf   tailtrack, W, A
    bz      reset_tailright ; Branch to reset_count if snake loc.
			     ; and headtailcheck are equal
			     
    continue_r:
    movf    tailtrack, W, A
    movwf   taily1, A
    movf    tailtrack, W, A
    movwf   tailx1, A
    incf    tailx1, A
     
    incf    tailmemcount, A
    incf    tailmemcount, A
    
    ; Increment time
    INCF time_inc, A
    return
    
reset_countdown:
    clrf    tailmemcount, A
    goto    continue_down
    
reset_countup:
    clrf    tailmemcount, A
    goto    continue_up
    
reset_countleft:
    clrf    tailmemcount, A
    goto    continue_left
    
reset_countright:
    clrf    tailmemcount, A
    goto    continue_right
    
reset_taildown:
    movf    snake_size, W, A
    movwf   tailtrack, A
    decf    tailtrack, A
    goto    continue_d
    
reset_tailup:
    movf    snake_size, W, A
    movwf   tailtrack, A
    decf    tailtrack, A
    goto    continue_u
    
reset_tailleft:
    movf    snake_size, W, A
    movwf   tailtrack, A
    decf    tailtrack, A
    goto    continue_l
    
reset_tailright:
    movf    snake_size, W, A
    movwf   tailtrack, A
    decf    tailtrack, A
    goto    continue_r
    
clearTail:
    movf    tailx1, W, A
    movwf   FSR0, A
    movf    INDF0, W, A
    movwf   tempX, A
    movf    taily1, W, A
    movwf   FSR0, A
    movf    INDF0, W, A
    movwf   tempY, A
    
    call    XYConv
    call GLCD_clearPix
    return
writeHead:
    movf snake, W, A
    movwf tempY, A
    movf snake+1, W, A
    movwf tempX, A
    call XYConv
    call GLCD_lightPix
    return
    


