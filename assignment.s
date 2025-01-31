; displaying initials
.equ SREG, 0x3f		  ; Status register
.equ DDRB, 0x04		  ; Register defining pins on port B to be input (0) or output (1)
.equ PORTB, 0x05	  ; Output port for PORTB
.equ DDRD, 0x0A		  ; 
.equ PORTD, 0x0B	  ; output port for PORTD

.org 0                    ; .org specifies the start address

          ; reset system status
main:     ldi r16, 0      
          out SREG,r16    ; set SREG to 0

		          ; set port bits to output mode
          ldi r16, 0x0F   ; set r16 to 0x0F -> switch on bit 0 to bit 3-> bit 0 to 3 is output
          out DDRB,r16    ; copy the value to DDRB

	  ldi r16, 0xF0   ; set port bits to output mode
	  out DDRD, r16   ; set r16 to 0xf0 -> switch on bit 4 to bit 7 ->bit 4 to 7 is output

	  ldi r21, 0

;Display Knumber

	  ldi r16, 0x02   ; turn LED ON to display 2
	  call display	  ; display subroutine turns on led respective to value loaded in r16
          ldi r19, 100    ; delay 1s
          call delay      ; delay subroutine executes delay in increments of 10ms, hence 10 x 10 = 100ms 

          ldi r16, 0x03   ; turn LED ON to display 3
	  call display
          ldi r19, 100    ; delay 1s
          call delay      ; 

	  ldi r16, 0x00   ; turn LED ON to display 0
	  call display
          ldi r19, 100    ; delay 1s
          call delay  

	  ldi r16, 0x09   ; turn LED ON to display 9
	  call display
          ldi r19, 100    ; delay 1s
          call delay  

	  ldi r16, 0x02   ; turn LED ON to display 2
	  call display
          ldi r19, 100    ; delay 1s
          call delay  

	  ldi r16, 0x09   ; turn LED ON to display 9
	  call display
          ldi r19, 100    ; 1s
          call delay  

	  ldi r16, 0x07   ; turn LED ON to display 7
	  call display
          ldi r19, 100    ; 1s
          call delay  

	  ldi r16, 0x02   ; turn LED ON to display 2
	  call display
	  ldi r19, 100    ; 1s
          call delay  
	  
	  ldi r16, 0x00   ; TURN OFF LED
	  call display
	  ldi r19, 100    ; delay 1s
          call delay  

; Display Initials
;J in binary

	  ldi r16, 0x0A   ; J in binary
	  call display

          ldi r19, 100    ; delay 1s
          call delay      ; 

          ldi r16, 0x1B   ; "." In binary
	  call display

          ldi r19, 100    ; delay 1s
          call delay      ; 

	  ldi r16, 0x13   ; S in binary
	  call display

          ldi r19, 100    ; delay 1s
          call delay  

	  ldi r16, 0x00   ; TURN OFF LED
	  call display

          ldi r19, 100    ; delay 1s
          call delay  

;begin morse program
	  ldi r21, 0	  ; start counter at 0

MORSE: 
	  inc r21	  ; increments counter by 1
	  cpi r21, 1	  ; given n iterations, upper limit set to n + 1 (i.e. for 50 iterations, upper limit = 51)
	  brlo EVENORODD  ; skip pingpong program until 50 iterations of morse are complete

; Display Pingpong
          ;load 0x80 to start the pingpong program at bit 7
          ldi r16, 0x80
	  call display	 

	  ldi r19, 10     ; delay 100 milliseconds
          call delay	  

PINGPONG:   
	  ldi r22, 14	  ; sets counter to 14, there are 14 shifts back and forth when traversing along
			  ; 8 LEDs
	  
Loop1:	  lsr r16	  ; shifts bit displayed to the right using a right logic shift(LSR)
	  call display

	  ldi r19, 10     ; delay 100 milliseconds
          call delay 
	  
	  dec r22
	  cpi r22, 7	  
	  brne Loop1	  ; loops 7 times to the other side with 8 LEDs

Loop2:    lsl r16
	  call display

	  ldi r19, 10     ; delay 100 milliseconds
          call delay  
	  
	  dec r22
	  cpi r22, 0
	  brne Loop2	  ; loops another 7 times to the other side
	  rjmp PINGPONG
	  
EVENORODD:		  ; checks if iteration if even or odd
	  SBRS r21, 0 	  ; skips following command if bit 0 is set(signalling odd iteration), 
	  rjmp IF_EVEN	  ; jumps to IF_EVEN if bit 0 is cleared(signalling even iteration)

; executes morsecode patterns using subroutines 
IF_ODD:
;J in morse (. _ _ _ )

	  call DOT
	  call PARTBREAK
	  call STROKE3
	  call LETTERBREAK

;O in morse ( _ _ _ )
	
	  call STROKE3
	  call LETTERBREAK

;A in morse (. _ )
	   
	  call DOT
	  call PARTBREAK
	  call STROKE
          call MOD5CHECK
	  jmp MORSE

IF_EVEN:

;A in morse (. _ )
	   
	  call DOT
	  call PARTBREAK
	  call STROKE
	  call LETTERBREAK

;O in morse ( _ _ _ )
	
	  call STROKE3
	  call LETTERBREAK

;J in morse (. _ _ _ )

call DOT
	  call PARTBREAK
	  call STROKE3
	  call MOD5CHECK
	  jmp MORSE

; Subroutines
; IF5 subroutine
IF5:	  
	  ldi r16, 0x00   ; turn LED OFF 
	  call display

          ldi r19, 40     ; delay 400 milliseconds
          call delay   
	  
;display 5 in morse (. . . . .)
	  ldi r23, 5	  ;5 iteration of loops
	 
Loop5:	  
	  call PARTBREAK
	  call DOT
	  dec r23
	  cpi r23, 0
	  brne Loop5
	  call WORDBREAK
	  ret

; Modulo 5 Check subroutine
MOD5CHECK:
	  mov r22, r21	  ; initialise r22 by loading value from r21(counter) into r22
	  cpi r22, 5	  ; check if value == 5
	  breq IF5	  ; if value == 5, execute IF5 subroutine to display 5 in morsecode
loopmod:
	  brlo RETURN	  ; if value is below 5, it is not a multiple of 5, return to MORSE loop
	  subi r22, 5	  ; decrement r22 by 5
	  cpi r22, 5
	  breq IF5	  ; if value == 5, iteration is a multiple of 5 
	  rjmp loopmod	  ; repeat loop

RETURN: 
	  call WORDBREAK  
	  ret	 	  ; return to MORSE loop

;Morse subroutine
DOT:	  ldi r16, 0xFF   ; first dot
	  call display

          ldi r19, 20     ; delay 200 milliseconds
          call delay      ; 
	  ret

STROKE:
	  ldi r16, 0xFF   ; first stroke
	  call display

          ldi r19, 60     ; delay 600 milliseconds
          call delay  
	  ret

STROKE3:
	  ldi r16, 0xFF   ; first stroke
	  call display

          ldi r19, 60     ; delay 600 milliseconds
          call delay  

	  ldi r16, 0x00   ; turn LED OFF
	  call display

          ldi r19, 20     ; delay 200 milliseconds
          call delay  

	  ldi r16, 0xFF   ; second stroke
	  call display

          ldi r19, 60     ; delay 600 milliseconds
          call delay  

	  ldi r16, 0x00   ; turn LED OFF
	  call display

          ldi r19, 20     ; delay 200 milliseconds
          call delay  

	  ldi r16, 0xFF   ; third stroke
	  call display

          ldi r19, 60     ; delay 600 milliseconds
          call delay  
	  ret
	  
PARTBREAK:
	  ldi r16, 0x00   ; turn LED OFF 
	  call display

          ldi r19, 20     ; delay 200 milliseconds
          call delay      ; 
	  ret

LETTERBREAK: 
	  ldi r16, 0x00   ; turn LED OFF 
	  call display

          ldi r19, 60     ; delay 600 milliseconds
          call delay      ; 
	  ret

WORDBREAK: 
	  ldi r16, 0x00   ; turn LED OFF 
	  call display

          ldi r19, 140    ; delay 1400 milliseconds
          call delay      ; 
	  ret

; delay subroutine - creates delay by increments of 10ms
delay:    ldi r17, 255 
          ldi r18,  126
          ; inner loop is 5 cycles so 1 outer loop iteration is - 
          ; 5 cycles x r17 x r18 = 
          ; 5 cycles x 255 x  126 = 160650 cycles
          ; 160650 cycles / 16,000,000 = 0.010040625 seconds (~10 ms) 
loop1:    nop        ; 1 cycle
          dec r17    ; 1 cycle
          cpi r17, 0 ; 1 cycle
          brne loop1 ; 2 cycles
          ldi r17, 255 ; reset inner loop
          dec r18
          cpi r18, 0
          brne loop1
          ldi r18, 126 ; reset first outer loop
          dec r19
          cpi r19, 0
          brne loop1
          ret	  
; display subroutine
display:
	  out PORTB, r16  ; write register 16 to portB
	  out PORTD, r16  ; write register 16 to portD
	  ret


	  