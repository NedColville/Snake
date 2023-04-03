	#include <xc.inc>

global time_inc, snake, Snake_move, Eat_apple, tailmemcount, tailtemp, tailtrack
global seed, coefa, coefc, coefm, aX0low, aX0high, aX0plusc
global seed2, coefa2, coefc2, coefm2, aX0low2, aX0high2, aX0plusc2
global up, down, left, right, mover, tailx1, tailx2, taily1, taily2
global Snake_init, getApple, Eat_apple, Snake_move, headtailcheck, offset, offset2
extrn  move_up, move_down, move_left, move_right, LCG_generator, LCG_generator2
extrn keyboardRead, GLCD_lightPix, XYConv, GLCD_clearPix, tempX, tempY
extrn start, mover,lengthCounter, keyboardRead,snake_size, endgame
	
psect udata_acs
 
; Memory location for time increments, snake's INITIAL head position
; AND incrementer for position of snake's added body parts
    time_inc:	ds 1
    snake:	ds 0x11
    snake_inc:	ds 1
    tailx1:	ds 1
    tailx2:	ds 1
    taily1:	ds 1
    taily2:	ds 1
    tailmemcount: ds 1
    collCounter: ds 1
    headtailcheck:    ds 1
    offset:	    ds 1
    tailtemp: ds 1
    offset2: ds 1
    tailtrack: ds 1
    collPos: ds 1
    tempCounter: ds 1
   
	    
; Define constants for direction values
    up     equ 0xBD ;values from the keyboard corresponding to each button press
    down   equ 0xED
    left   equ 0xDB
    right  equ 0xDE
    pause  equ 0x7B
    restart equ	0x7D
 
 
    
; Define the memory locations needed for the apple generation
    ; x values
    seed:	ds 1 ; seed
    coefa:	ds 1 ; multiplier a
    coefc:	ds 1 ; increment c
    coefm:	ds 1 ; modulus m 
    aX0low:	ds 1 ; temp store for prod of a*X0 low byte
    aX0high:	ds 1 ; temp store for prod of a*X0 high byte
    aX0plusc:	ds 1 ; temp store for a*X0 + c
	
    ; y values
    seed2:	ds 1
    coefa2:	ds 1
    coefc2:	ds 1
    coefm2:	ds 1
    aX0low2:	ds 1
    aX0high2:	ds 1
    aX0plusc2:	ds 1
	
psect logM, class=CODE
  
;rst:	org 0x00
;goto	Snake_init
  
;org	0x100

Snake_init:
    ; Initialize snake's initial coordinates (3 x vals, 3 y vals)
    MOVLW 0x09	    ; head	    
    MOVWF snake, A
    movwf tempY, A
    MOVLW 0x04	    ; head	    
    MOVWF snake+1, A
    movwf tempX, A
    call XYConv
    call GLCD_lightPix
    
    MOVLW 0x08	    ; body
    MOVWF snake+2, A
    movwf tempY, A
    MOVLW 0x04	    ; body
    movwf tempX, A
    MOVWF snake+3, A
    call XYConv
    call GLCD_lightPix
    
    
    MOVLW 0x07	    ; body
    MOVWF snake+4, A
    movwf tempY, A
    MOVLW 0x04	    ; body
    MOVWF snake+5, A
    movwf tempX, A
    call XYConv
    call GLCD_lightPix
    
    movlw	0x00
    movwf	tailmemcount, A
    
    ; Track time increments for a single press to make sure it turns correctly
    ; (Note snake head turns while rest of body still moving same direction)
    MOVLW 0
    MOVWF time_inc, A	; Initialize time to 0
    
    movlw   0x05
    movwf   taily1, A
    movlw   0x06
    movwf   tailx1, A
    
    movf    snake_size, A
    movwf   tailtrack, A
    decf    tailtrack, A
    
    return

    
    
     
getApple:
    bra LCG_xinit
LCG_xinit:
    ; initialise the LCG with seed value
    movlw   0x07 ; define seed value
    movwf   seed, A ; store seed value in a memory location named 'seed'

    ; define the other constants for the LCG
    movlw   0x05
    movwf   coefa, A
    movlw   0x01
    movwf   coefc, A
    movlw   0x10
    movwf   coefm, A
    
LCG_yinit:
    ; initialise the LCG with seed value
    movlw   0x03 ; define seed value
    movwf   seed2, A ; store seed value in a memory location named 'seed'

    ; define the other constants for the LCG
    movlw   0x05
    movwf   coefa2, A
    movlw   0x01
    movwf   coefc2, A
    movlw   0x08
    movwf   coefm2, A
    
Apple_display:
    
    call    LCG_generator
    movff seed, tempY
    call    LCG_generator2
    movff seed2, tempX
    call XYConv
    call GLCD_lightPix
     
   return
    
    
Eat_apple:
    ; Check if the head of the snake is in the same coordinate as the apple
    movf    snake, W, A	    ; movf for moving VALUE IN SNAKE memory
			    ; not value assigned to snake
    cpfseq  seed	    ; check if the head x is equal to apple x
    goto    Snake_move	    ; If not, skip to Snake_move
    movf    snake+1, W, A
    cpfseq  seed2	    ; check if the head y is equal to apple y
    goto    Snake_move

    ; If the head is in the same coordinate as the apple, increase the snake length
    ; Allocate memory for a new node using snake + snake_inc
    incf    snake_inc, F, A    ; Increment snake_inc to point to the next available memory location
    movlw   snake
    addwf   snake_inc, W, A
    movwf   FSR0, A
    movf    seed, W, A	    ; Get the x-coordinate of the apple
    movwf   INDF0, A ; Store the x-coordinate in the new node
    incf    snake_inc, F, A    ; Increment snake_inc to point to the next available memory location
    movlw   snake
    addwf   snake_inc+1, W, A
    movwf   FSR0, A
    movf    seed2, W, A	    ; Get the x-coordinate of the apple
    movwf   INDF0, A	    ; Store the y-coordinate in the new node
    
    call    Apple_display


    
Snake_move:   
  
    ; Call function which converts user signal into one of the 4 values given above
    ; Put value into 'mover'

    
    ; Check the value of mover and call move_snake subroutine
    movlw   up        ; Load up value to W register
    xorwf   mover, W, A  ; Compare W (up) with mover - sets W = 0 if equal, 1 o.w.
    btfsc   STATUS, 2, A ; Skip next instruction if W = 1
    call    move_up  ; Call move_pos subroutine

    movlw   down      ; Load down value to W register
    xorwf   mover, W, A  ; Compare W with mover
    btfsc   STATUS, 2 , A; Skip next instruction if W and mover are not equal
    call    move_down  ; Call move_neg subroutine

    movlw   left      ; Load left value to W register
    xorwf   mover, W, A  ; Compare W with mover
    btfsc   STATUS, 2, A ; Skip next instruction if W and mover are not equal
    call    move_left  ; Call move_neg subroutine

    movlw   right     ; Load right value to W register
    xorwf   mover, W, A  ; Compare W with mover
    btfsc   STATUS, 2, A ; Skip next instruction if W and mover are not equal
    call    move_right  ; Call move_pos subroutine
    
    movlw   pause     ; Load right value to W register
    xorwf   mover, W, A  ; Compare W with mover
    btfsc   STATUS, 2, A ; Skip next instruction if W and mover are not equal
    call    do_pause  ; Call pause subroutine
    
    movlw   restart     ; Load restart value to W register
    xorwf   mover, W, A  ; Compare W with mover
    btfsc   STATUS, 2, A ; Skip next instruction if W and mover are not equal
    call    start  ; Go back to start
    
    return

do_pause:
    call keyboardRead
    movlw   right     ; Load pause value to W register
    xorwf   mover, W, A  ; Compare W with mover
    btfsc   STATUS, 2, A ; Skip next instruction if W and mover are not equal
    bra do_pause
    bra Snake_move
    
collisionStart:
    movlw 0x00 ;load 0 to counter
    movwf collCounter, A
    movlw snake ;want to test values after snake in memory so load snake memory address
    movwf collPos, A
    incf collPos, A
    incf collPos, A ;increase for testing
    
horzCheck:
    movf   collPos, W, A      ; Load down value to W register
    xorwf   snake, W, A  ; Compare W with snake
    btfsc   STATUS, 2 , A; Skip next instruction if W and mover are not equal
    call    vertCheck  ; Call move_neg subroutine
    
    incf collPos, A
    incf collPos, A
    incf collCounter, A
    incf collCounter, A
    movf collCounter, W, A
    cpfsgt snake_size, A
    bra horzCheck
    return
    
vertCheck:
    incf collPos, A
    movf collPos, W, A
    xorwf   snake+1, W, A  ; Compare W with snake
    btfsc   STATUS, 2 , A; Skip next instruction if W and mover are not equal
    goto endgame  ; Call move_neg subroutine
    decf collPos, A
    return
    

    
    
    
    
    
    
    
    
    
    




