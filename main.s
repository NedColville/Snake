#include <xc.inc>

extrn	GLCD_display_on, GLCD_display_off,GLCD_output, GLCD_sety, GLCD_setx, set_IO, GLCD_pickPageL, send_I, send_D

psect	code, abs
rst:
    org	0x0
    goto start
; Main code starts here at address 0x100
start:
    nop
    org	0x100
    call set_IO
    nop
    call GLCD_display_on
    call GLCD_pickPageL
    movlw 0x00
    call GLCD_sety
    movlw 00000000B
    call GLCD_setx
    movlw 11111111B
    movwf 0x01
    movlw 00000100B
    movwf 0x02
    
write2:
    call write
    decfsz 0x02
    bra write2
write:
    movlw 0xFF
    call send_D
    decfsz 0x01
    bra write
    return
