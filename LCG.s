	#include <xc.inc>
	
psect code 
global LCG_generator, LCG_generator2
extrn seed, coefa, coefc, coefm, aX0low, aX0high, aX0plusc
extrn seed2, coefa2, coefc2, coefm2, aX0low2, aX0high2, aX0plusc2

; x values
LCG_generator:  
    
    movf  coefa, W, A	; Load LCG multiplier into W register
    mulwf seed	, A	; Multiply current seed by LCG multiplier
    movff PRODL, aX0low	; Move low byte of result to aX0
    movff PRODH, aX0high; Move high byte of result to aX0+1
    movf  coefc, W, A	; Load increment c into W register
    addwf aX0low, W, A	; Add increment c to aX0
    movwf aX0plusc, A	; Store result in temporary register aX0plusc
    movf  aX0high, W, A	; Move high byte into W register
    addwf aX0plusc, W, A	; Add high byte to low byte+c
    
    call    LCG_division_loop  ; Compute remainder using repeated subtraction of modulus aX0plusc
    
LCG_division_loop:
    movf    coefm, W, A		; Load m into W register
    subwf   aX0plusc, 0		; Subtract m from aX0plusc, put result in W
    cpfsgt  aX0plusc, A		; Check if aX0 < m, skip next line otherwise
    goto    LCG_division_done	; If underflowed, skip to division done
    movwf   aX0plusc, A		; Store result of subtraction back in aX0plusc
    goto    LCG_division_loop	; Repeat until product is less than modulus
    
LCG_division_done: 
    ; aX0plusc is the modulus now because it is the last value before underflow (<0)
    movf  aX0plusc, W, A	; Move remainder to W register
    movwf seed, A		; Store as new seed = random number generated
    return		; Return to main

    
; y values
LCG_generator2:  
    
    movf  coefa2, W, A	    ; Load LCG multiplier into W register
    mulwf seed2	, A	    ; Multiply current seed by LCG multiplier
    movff PRODL, aX0low2    ; Move low byte of result to aX0
    movff PRODH, aX0high2   ; Move high byte of result to aX0+1
    movf  coefc2, W, A	    ; Load increment c into W register
    addwf aX0low2, W, A	    ; Add increment c to aX0
    movwf aX0plusc2, A	    ; Store result in temporary register aX0plusc
    movf  aX0high2, W, A	    ; Move high byte into W register
    addwf aX0plusc2, W, A	    ; Add high byte to low byte+c
    
    call    LCG_division_loop2  ; Compute remainder using repeated subtraction of modulus aX0plusc
    
LCG_division_loop2:
    movf    coefm2, W, A		; Load m into W register
    subwf   aX0plusc2, 0		; Subtract m from aX0plusc, put result in W
    cpfsgt  aX0plusc2, A		; Check if aX0 < m, skip next line otherwise
    goto    LCG_division_done2	; If underflowed, skip to division done
    movwf   aX0plusc2, A		; Store result of subtraction back in aX0plusc
    goto    LCG_division_loop2	; Repeat until product is less than modulus
    
LCG_division_done2: 
    ; aX0plusc is the modulus now because it is the last value before underflow (<0)
    movf  aX0plusc2, W, A	; Move remainder to W register
    movwf seed2, A		; Store as new seed = random number generated
    return		; Return to main


