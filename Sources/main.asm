;**************************************************************************************
;* Blank Project Main [includes LibV2.2]                                              *
;**************************************************************************************
;* Summary:                                                                           *
;*   -                                                                                *
;*                                                                                    *
;* Author: Noah Tanner, Cole Sterba                                                   *
;*   Cal Poly University                                                              *
;*   Spring 2022                                                                      *
;*                                                                                    *
;* Revision History:                                                                  *
;*   -                                                                                *
;*                                                                                    *
;* ToDo:                                                                              *
;*   place result of ASCII - BCD in ticks1/2                                          *
;*   M2 tasks                                                                         *
;*   connect M2 and display, define all vars                                          *
;*   Error display                                                                    *
;*   Pattern task stops when waiting for new time input                               *
;**************************************************************************************

;/------------------------------------------------------------------------------------\
;| Include all associated files                                                       |
;\------------------------------------------------------------------------------------/
; The following are external files to be included during assembly


;/------------------------------------------------------------------------------------\
;| External Definitions                                                               |
;\------------------------------------------------------------------------------------/
; All labels that are referenced by the linker need an external definition

              XDEF  main

;/------------------------------------------------------------------------------------\
;| External References                                                                |
;\------------------------------------------------------------------------------------/
; All labels from other files must have an external reference

              XREF  ENABLE_MOTOR, DISABLE_MOTOR
              XREF  STARTUP_MOTOR, UPDATE_MOTOR, CURRENT_MOTOR
              XREF  STARTUP_PWM, STARTUP_ATD0, STARTUP_ATD1
              XREF  OUTDACA, OUTDACB
              XREF  STARTUP_ENCODER, READ_ENCODER
              XREF  INITLCD, SETADDR, GETADDR, CURSOR_ON, CURSOR_OFF, DISP_OFF
              XREF  OUTCHAR, OUTCHAR_AT, OUTSTRING, OUTSTRING_AT
              XREF  INITKEY, LKEY_FLG, GETCHAR
              XREF  LCDTEMPLATE, UPDATELCD_L1, UPDATELCD_L2
              XREF  LVREF_BUF, LVACT_BUF, LERR_BUF,LEFF_BUF, LKP_BUF, LKI_BUF
              XREF  Entry, ISR_KEYPAD
            
;/------------------------------------------------------------------------------------\
;| Assembler Equates                                                                  |
;\------------------------------------------------------------------------------------/
; Constant values can be equated here

PORTP         EQU   $0258              ; output port for LEDs
DDRP          EQU   $025A
G_LED_1       EQU   %00010000          ; green LED output pin for LED pair_1
R_LED_1       EQU   %00100000          ; red LED output pin for LED pair_1
LED_MSK_1     EQU   %00110000          ; LED pair_1

R_LED_2       EQU   %01000000          ; green LED output pin for LED pair_2
G_LED_2       EQU   %10000000          ; red LED output pin for LED pair_2
LED_MSK_2     EQU   %11000000          ; LED pair_2

;/------------------------------------------------------------------------------------\
;| Variables in RAM                                                                   |
;\------------------------------------------------------------------------------------/
; The following variables are located in unpaged ram

DEFAULT_RAM:  SECTION

CHAR_RDY      DS.B    1              ; flag to display when character ready
BUFFER        DS.B    5             ; Buffer for time inputs
BUFFCOUNT     DS.B    1
DSPCOUNT      DS.B    1
DSPSTART      DS.B    1
MESSFIN       DS.B    1
F1_FLG        DS.B    1
F2_FLG        DS.B    1
BIN_RES       DS.W    1            ; word is two bytes
TICKS_1       DS.W    1            ; ms count for LED set 1
TICKS_2       DS.W    1            ; ms count for LED set 2
PAT1_DONE     DS.B    1            ; done flag for LED set 1
PAT2_DONE     DS.B    1            ; done flag for LED set 1
PAT1_COUNT    DS.W    1            ; delay count for LED set 1
PAT2_COUNT    DS.W    1            ; delay count for LED set 2
EDELCOUNT     DS.W    1            ; counter for error message delay
T2_FLG        DS.B    1           
T1_FLG        DS.B    1
F2ENTR_FLG    DS.B    1
ERR1_FLG      DS.B    1
ERR2_FLG      DS.B    1
ERR3_FLG      DS.B    1
ECHO_FLG      DS.B    1
TEMP          DS.B    1
CLRF1_FLG     DS.B    1
CLRF2_FLG     DS.B    1
DELAY         DS.B    1
ERR_FLG       DS.B    1
KEY_BUFF      DS.B    1
F1ENTR_FLG    DS.B    1
EDEL_FLG      DS.B    1
COUNT         DS.B    1
DPTR          DS.B    1
BS_FLG        DS.B    1
ACCINPUT      DS.B    1
FKEYSTATE     DS.B    1
PAT1_ON       DS.B    1
PAT2_ON       DS.B    1
T1S1RUN1      DS.B    1

t1state       DS.B    1
t2state       DS.B    1
t3state       DS.B    1
t4state       DS.B    1
t5state       DS.B    1
t6state       DS.B    1
t7state       DS.B    1
t8state       DS.B    1
exit_t1s1     DS.B    1



;/------------------------------------------------------------------------------------\
;|  Main Program Code                                                                 |
;\------------------------------------------------------------------------------------/
; Your code goes here

MyCode:       SECTION
main:   
            clr     t1state
            clr     t2state
            clr     t3state
            clr     t4state
            clr     t5state
            clr     t6state
            clr     t7state
            clr     t8state

Loop:       jsr     TASK_1          ; Mastermind
            jsr     TASK_2          ; keypad
            jsr     TASK_3          ; display
            jsr     TASK_4          ; pattern 1
            jsr     TASK_5          ; timing 1
            jsr     TASK_6          ; pattern 2
            jsr     TASK_7          ; timing 2
            jsr     TASK_8          ; delay
            bra     Loop            ; repeat


;-------------------------------TASK_1 Mastermind----------------------------------------

TASK_1:     ldaa    t1state         ; get current branch, branch accordingly
            lbeq    t1state0
            deca 
            lbeq    t1state1
            deca
            lbeq    t1state2
            deca
            lbeq    t1state3
            deca  
            lbeq    t1state4
            deca
            lbeq    t1state5
            deca 
            lbeq    t1state6
            deca
            lbeq    t1state7
            rts                      
        
t1state0:                           ; init task 1
            clr     T1S1RUN1
            clr     CHAR_RDY
            clr     KEY_BUFF
            clr     ACCINPUT
            clr     BUFFCOUNT
            clr     ERR_FLG
            clr     F1ENTR_FLG
            clr     F2ENTR_FLG
            clr     FKEYSTATE
            clrw    BIN_RES         
            clr     PAT1_ON
            clr     PAT2_ON
            movb    #$01, t1state   ; set next state
            rts 

t1state1:                           ; base messages on LCD
            tst     T1S1RUN1        ;variable to ensure setting flags occurs only once 
            bne     t1s1test        ;test if it is first run thru
            movb    #$01, T1_FLG    ; set T1 flag
            movb    #$01, T2_FLG
            movb    #$01, F1_FLG
            movb    #$01, F2_FLG
            movb    #$01, T1S1RUN1  
t1s1test:   tst     T1_FLG          ; test all flags
            bne     t1s1skip         
            tst     T2_FLG
            bne     t1s1skip 
            tst     F1_FLG
            bne     t1s1skip 
            tst     F2_FLG
            bne     t1s1skip
            clr     T1S1RUN1
            movb    #$02, t1state   ;if all flags are zero, go to hub state                
t1s1skip:   
            rts

t1state2:                           ; hub
            tst     CHAR_RDY
            beq     SKIP_CHAR       ; if no character ready, skip key handling
            ldaa    KEY_BUFF
            clr     CHAR_RDY        ; clear CHAR_RDY
            cmpa    #$F1            ; check value of A to determine branch (key handling)
            lbeq    F1key           ; branch to set F1 flag
            cmpa    #$F2
            lbeq    F2key           ; branch to set F2 flag
            cmpa    #$30
            bhs     set_t1s3
            cmpa    #$08
            lbeq    set_t1s6
            cmpa    #$0A
            lbeq    set_t1s7
            clr     CHAR_RDY
SKIP_CHAR:  rts

set_t1s3:   ldaa    BUFFCOUNT
            cmpa    #$05
            bhs     dontdisp
            movb    #$03, t1state   ;set state variable
dontdisp:   rts
set_t1s6:   tst     BUFFCOUNT       ;test BUFFCOUNT
            beq     dontdelete      ;if 0, dont jump states
            movb    #$06, t1state   ;set state variable
dontdelete: rts 
set_t1s7:   movb    #$07, t1state   ;set state variable
            rts
            
F1key:      tst     F2ENTR_FLG
            bne     Fkeyskip
            tst     F1ENTR_FLG
            bne     Fkeyskip 
            movb    #$01, FKEYSTATE ;set F key state variable
            movb    #$05, t1state
Fkeyskip:   rts

F2key:      tst     F1ENTR_FLG
            bne     Fkeyskip
            tst     F2ENTR_FLG
            bne     Fkeyskip
            movb    #$02, FKEYSTATE ;set F key state variable 
            movb    #$05, t1state 
            rts 

t1state3:   ldaa    KEY_BUFF        ; digit handler
            cmpa    #$3E            ; ensure it is an ascii digit
            bhs     t1s3skip
            tst     ACCINPUT        ; test if digits are to be accepted
            beq     t1s3skip        ; ignore digit if not ready
            movb    #$01, ECHO_FLG  ; set echo flag high
            ldx     #BUFFER         ; load buffer address into x
            ldaa    BUFFCOUNT       ; load amount of digits in buffer into a
            ldab    KEY_BUFF        ; store digit in buffer
            stab    A, X            ; store the digit into BUFFER
            clr     CHAR_RDY        ; clear the character ready flag
            inc     BUFFCOUNT       ; inc BUFFCOUNT
t1s3skip:   movb    #$02, t1state   ; move back to hub state
            rts
    
t1state4:                           ; error handler    
            ldab    ERR_FLG
            cmpb    #$03
            beq     t1state4a       ; error 3 branch (Zero error)
            cmpb    #$02
            beq     t1state4b       ; error 2 branch (Nothing Entered)
            cmpb    #$01
            beq     t1state4c       ; error 1 branch (TDB)
            cmpb    #$04
            beq     t1state4d       ; waiting state
            movb    #$01, t1state   ; reset to hub state
            rts

t1state4a:
            movb    #$01, ERR3_FLG
            movb    #$04, ERR_FLG
            rts
t1state4b:
            movb    #$01, ERR2_FLG
            movb    #$04, ERR_FLG
            rts
t1state4c:            
            movb    #$01, ERR1_FLG
            movb    #$04, ERR_FLG
            rts
t1state4d:  
            rts

t1state5:                           ; F1/F2 key handler (substates a, b set flags)
            ldaa    FKEYSTATE
            cmpa    #$01
            beq     F1
            cmpa    #$02
            beq     F2
            tst     CLRF1_FLG
            beq     t1s5done
            tst     CLRF2_FLG
            beq     t1s5done
            rts
t1s5done:   movb    #02, t1state       ; move back to mastermind hub state
            rts
            
F1:         movb    #$01, CLRF1_FLG ; set F1 flag so display can react
            movb    #$01, ACCINPUT  ; flag to notify digit handler input is now accepted
            movb    #$01, F1ENTR_FLG; flag to notify enter key where to put things
            clr     PAT1_ON
            clr     FKEYSTATE
            clr     CHAR_RDY 
            rts 

F2:         movb    #$01, CLRF2_FLG ; set F2 flag so display can react
            movb    #$01, ACCINPUT  ; flag to notify digit handler input is now accepted
            movb    #$01, F2ENTR_FLG; flag to notify enter key where to put things
            clr     PAT2_ON
            clr     FKEYSTATE
            clr     CHAR_RDY
            rts
             
t1state6:                           ; backspace
            ldaa   BS_FLG           ; load BS_FLG into a
            cmpa   #$04             ; compare BS_FLG to 4
            beq    t1s6done
            tst    BS_FLG
            bne    t1s6skip    
            movb   #$01, BS_FLG     ; set backspace flag so display can react
            ldx    #BUFFER          ; load buffer address into x
            ldaa   BUFFCOUNT        ; load amount of digits in buffer into a
            suba   #$01             ; subtract 1 from A
            ldab   #$00             ; store digit in buffer
            stab   A, X             ; store the digit into BUFFER
            dec    BUFFCOUNT        ; decrement BUFFCOUNT by 1
            rts
t1s6done:   movb   #$02, t1state    ; move back to mastermind hub state
            clr    BS_FLG           ; reset BS_FLG
t1s6skip:   rts       

t1state7:                           ; enter key
            tst   F1ENTR_FLG        ; check if F1 flag has been set
            bne   t1s7cont        
            tst   F2ENTR_FLG        ; check if F2 flag has been set
            bne   t1s7cont        
            bra   t1s7skip          ;if no f key was pressed, dont do anything with enter
t1s7cont:   ldx   #BUFFER
            clr   ACCINPUT          ; digits can no longer be input to the buffer
            clrw  BIN_RES           ; clear bin_res
            tst   BUFFCOUNT         ; test BUFFCOUNT for 0
            beq   NODIGerror        ; branch to NODIGITS error
            jsr   ASC_BIN           ; convert ASCII to Binary, stores result in BIN_RES
            cmpa  #$01              ; compare a to 1, checking for TDB error 
            beq   TDBerror          ; branch to TDB error
            cmpa  #$02              ; compare a to 2, checking for zero error
            beq   ZEROerror         ; branch to ZERO error
            tst   F1ENTR_FLG        ; check if F1 flag has been set
            bne   F1_PRESSED        ; if F1 flag set, move to F1 press commands
            tst   F2ENTR_FLG        ; check if F2 flag has been set
            bne   F2_PRESSED        ; if F2 flag set, move to F2 press comands
t1s7skip:   movb  #$01, t1state     ; move back to mastermind hub state
            rts
TDBerror:                           ; number is too large
            movb  #$04, t1state     ; set error state
            movb  #$01, ERR_FLG
            clr   BUFFCOUNT
            rts

ZEROerror:                          ; number entered is zero
            movb  #$04, t1state     ; set error state
            movb  #$03, ERR_FLG     
            rts
NODIGerror:                         ; no digit has been entered error
            movb  #$04, t1state     ; set error state
            movb  #$02, ERR_FLG
            rts          
            
F1_PRESSED: 
            movw  BIN_RES, TICKS_1  ; stores converted value in ticks 1 to be used by timing 1
            clr   PAT1_COUNT        ;
            movb  #$01, PAT1_ON     ; set flag to turn on LED 1
            clr   F1ENTR_FLG        ; reset the F1 flag
            movb  #$01, t1state     ; move back to state
            rts

F2_PRESSED: 
            movw  BIN_RES, TICKS_2  ; stores converted value in ticks 2 to be usd by timing 2
            clr   PAT2_COUNT
            movb  #$01, PAT2_ON     ; set flag to turn on LED 2
            clr   F2ENTR_FLG        ; reset the F2 flag
            movb  #$01, t1state     ; set hub state    
            rts
            
;-------------------------------TASK_2 Keypad------------------------------------------

TASK_2:     ldaa  t2state           ; get current branch, branch accordingly
            beq   t2state0
            deca
            beq   t2state1
            deca  
            beq   t2state2
            
t2state0: 
            jsr   INITKEY           ; run keypad initialization
            movb  #$01, t2state     ; set next state
            rts

t2state1:   
            tst   LKEY_FLG          ; test for key available flag
            beq   exit_t2s1         ; exit if LKEY_FLG = 0
            jsr   GETCHAR           ; get the character from keypad
            stab  KEY_BUFF          ; store character in KEY_BUFF
            movb  #$01, CHAR_RDY    ; CHAR_RDY high so M2 grabs it next loop
            movb  #02, t2state      ; set next state
exit_t2s1:
            rts            

t2state2:                           ; check CHAR_RDY value
            tst   CHAR_RDY
            bne   exit_t2s2         ; if CHAR_RDY not cleared by M2, exit
            movb  #$01, t2state     ; set next state
exit_t2s2:
            rts
            
                        

;-------------------------------TASK_3 Display-----------------------------------------
TASK_3:
            ldaa  t3state           ; get current state of Display task
            beq   t3state0          ; init state
            deca
            beq   t3state1          ; hub state
            deca
            lbeq  t3state2          ; time 1 state
            deca
            lbeq  t3state3          ; time 2 state
            deca
            lbeq  t3state4          ; <F1> state
            deca
            lbeq  t3state5          ; <F2> state
            deca
            lbeq  t3state6          ; error 1 state
            deca
            lbeq  t3state7          ; error 2 state
            deca
            lbeq  t3state8          ; error 3 state
            deca
            lbeq  t3state9          ; backspace state
            deca
            lbeq  t3state10         ; clr <F2> state
            deca
            lbeq  t3state11         ; clr <F1> state
            deca
            lbeq  t3state12         ; echo state
            deca
            lbeq  t3state13         ; delay state
            rts                     ; jump back to main
                        
t3state0:                           ; startup state w/ base messages
            jsr   INITLCD           ; initialize the LCD screen for usage
            movb  #$01, t3state     ; set next state
            clr   T1_FLG
            clr   T2_FLG
            clr   F1_FLG
            clr   F2_FLG
            clr   CLRF1_FLG
            clr   CLRF2_FLG
            clr   ECHO_FLG
            clr   ERR1_FLG
            clr   ERR2_FLG
            clr   ERR3_FLG
            clr   BS_FLG
            clr   EDEL_FLG
            clr   MESSFIN
            clr   DSPCOUNT
            clr   BUFFCOUNT
            clr   TEMP
            clr   TICKS_1

t3state1:                           ; hub state
            tst   T1_FLG            ; check if need to display T1 message
            bne   DIS_T1_MESS       ; branch to display T1 message
            tst   T2_FLG            ; check if need to display T2 message
            bne   DIS_T2_MESS       ; branch to display T2 message
            tst   F1_FLG            ; check F1 flag
            bne   DIS_F1_MESS       ; branch to display F1 message if F1 flag high
            tst   F2_FLG            ; check F2 flag
            bne   DIS_F2_MESS       ; branch to display F2 message if F2 flag high
            tst   ERR1_FLG          ; check if number too big error
            bne   DIS_ERR1_MESS     ; branch to display too big error message
            tst   ERR2_FLG          ; check if need to no numbers error
            bne   DIS_ERR2_MESS     ; branch to display no numbers error
            tst   ERR3_FLG          ; check if need to display zero doesn't work error
            bne   DIS_ERR3_MESS     ; branch to display zzero doesn't work
            tst   BS_FLG            ; check BS flag
            bne   DIS_BSPCE_MESS    ; branch to display backspace message if BS flag high
            tst   CLRF1_FLG         ; check if need to display clear F1 message
            bne   DIS_CLRF1_MESS    ; branch to display clear F1 message
            tst   CLRF2_FLG         ; check if need to display clear F2 message
            bne   DIS_CLRF2_MESS    ; branch to display clear F2 message
            tst   ECHO_FLG          ; check echo flag
            bne   DIS_ECHO_MESS     ; branch to display clear echo message
            tst   EDEL_FLG          ; check error delay flag
            bne   DIS_EDEL_MESS     ; branch to error delay
            rts
            
DIS_T1_MESS:
            movb  #$02, t3state     ; move to T1
            rts
DIS_T2_MESS:
            movb  #$03, t3state     ; move to T2
            rts
DIS_F1_MESS:
            movb  #$04, t3state     ; move to F1
            rts            
DIS_F2_MESS:
            movb  #$05, t3state     ; move to 21
            rts            
DIS_ERR1_MESS:
            movb  #$06, t3state     ; move to Error 1: Number too large
            rts
DIS_ERR2_MESS:
            movb  #$07, t3state     ; move to Error 2: no value entered
            rts            
DIS_ERR3_MESS:
            movb  #$08, t3state     ; move to Error 3: zero doesn't work
            rts            
DIS_BSPCE_MESS:
            movb  #$09, t3state     ; move to backspace
            rts            
DIS_CLRF1_MESS:
            movb  #$0A, t3state     ; move to clear F1
            rts            
DIS_CLRF2_MESS:           
            movb  #$0B, t3state     ; move to clear F2
            rts            
DIS_ECHO_MESS:           
            movb  #$0C, t3state     ; move to display echo
            rts            
DIS_EDEL_MESS
            movb  #$0D, t3state     ; move to error delay
            movw  #$07D0, EDELCOUNT ; set count to 2000
            rts
                        
t3state2:                           ; time 1 msg
            ldx   #T1MESS
            movb  #$00, DSPSTART
            jsr   dispchar
            tst   MESSFIN
            beq   t3s2done
            movb  #$00, MESSFIN     ;reset MESSFIN
            movb  #$00, T1_FLG      ;reset T1_FLG to notify to completion of the msg
t3s2done:   rts            
            
t3state3:                           ; time 2 msg
            ldx   #T2MESS
            movb  #$40, DSPSTART
            jsr   dispchar
            tst   MESSFIN
            beq   t3s3done
            movb  #$00, MESSFIN     ;reset MESSFIN
            movb  #$00, T2_FLG      ;reset T2_FLG to notify to completion of the msg
t3s3done:   rts            
            
t3state4:                           ; <F1> msg
            ldx   #F1MESS
            movb  #$0E, DSPSTART
            jsr   dispchar
            tst   MESSFIN
            beq   t3s4done
            movb  #$00, MESSFIN     ;reset MESSFIN
            movb  #$00, F1_FLG      ;reset F1_FLG to notify to completion of the msg
t3s4done:   rts                                 

t3state5:                           ; <F2> msg
            ldx   #F2MESS
            movb  #$4E, DSPSTART
            jsr   dispchar
            tst   MESSFIN
            beq   t3s5done
            movb  #$00, MESSFIN     ;reset MESSFIN
            movb  #$00, F2_FLG      ;reset F2_FLG to notify to completion of the msg
t3s5done:   rts                     
            
t3state6:                           ; error 1 msg: Magnitude too large
            ldx   #ERROR1           ; load X with address of ERR
            movb  #$08, DSPSTART    ; set starting address for msg
            tst   F1ENTR_FLG
            bne   t3s6F1            
            movb  #$48, DSPSTART
t3s6F1:     jsr   dispchar
            tst   MESSFIN
            beq   t3s6done
            movb  #$00, MESSFIN     ; reset MESSFIN
            movb  #$00, ERR1_FLG    ; reset ERR1_FLG to notify to completion of the msg
            movb  #$01, EDEL_FLG    ; go to delay mode
            clr   F1ENTR_FLG
            clr   F2ENTR_FLG
t3s6done:   rts
         
t3state7:                           ; error 2 msg: No digits entered
            ldx   #ERROR2           ; load X with address of ERR
            movb  #$08, DSPSTART    ; set starting address for msg
            tst   F1ENTR_FLG
            bne   t3s7F1            
            movb  #$48, DSPSTART
t3s7F1:     jsr   dispchar
            tst   MESSFIN
            beq   t3s7done
            movb  #$00, MESSFIN     ; reset MESSFIN
            movb  #$00, ERR2_FLG    ; reset ERR2_FLG to notify to completion of the msg
            movb  #$01, EDEL_FLG    ; go to delay mode
            clr   F1ENTR_FLG
            clr   F2ENTR_FLG
t3s7done:   rts

t3state8:                           ; error 3 msg: 0 doesn't work
            ldx   #ERROR3           ; load X with address of ERR
            movb  #$08, DSPSTART    ; set starting address for msg
            tst   F1ENTR_FLG
            bne   t3s8F1            
            movb  #$48, DSPSTART
t3s8F1:     jsr   dispchar
            tst   MESSFIN
            beq   t3s8done
            movb  #$00, MESSFIN     ; reset MESSFIN
            movb  #$00, ERR3_FLG    ; reset ERR3_FLG to notify to completion of the msg
            movb  #$01, EDEL_FLG    ; go to delay mode
            clr   F1ENTR_FLG
            clr   F2ENTR_FLG
t3s8done:   rts
        
t3state9:                           ; backspace
            ldaa  BS_FLG            ; load x with bs flag
            cmpa  #$01              ; compare bs flag to 1
            bne   cp2               ; if not 1, skip
            ldab  #$08              ; load b with backspace char
            jsr   OUTCHAR           ; dsp backspace char
            movb  #$02, BS_FLG      ; set bs flag to 2
            rts 
cp2:   
            cmpa  #$02              ; compare bs flag to 2
            bne   cp3               ; if not 2, skip
            ldab  #$20              ; load b with space 
            jsr   OUTCHAR           ; dsp space char
            movb  #$03, BS_FLG      ; set bs flag to 3
            rts        
cp3:         
            cmpa  #$03              ; same as bs flag = 1
            ldab  #$08
            jsr   OUTCHAR
            movb  #$04, BS_FLG      ; clear BS flag for M2
            movb  #$01, t3state
            clr   CHAR_RDY          ; remove character ready flag
            rts                 

t3state10:                          ; clr F1
            ldx   #PROMPT           ; load X with address of prompt
            movb  #$08, DSPSTART    ; set starting address for msg
            jsr   dispchar          ; branch to dispchar
            tst   MESSFIN           ; test messfin
            beq   t3s10skip         ; if message isn't done, skip
            clr   MESSFIN           ; reset MESSFIN
            clr   CLRF1_FLG         ; clear msg flag
            ldaa  #$08              ; load a with 9
            jsr   SETADDR           ; set cursor location for echo
t3s10skip:  rts

t3state11:                          ; clr F2
            ldx   #PROMPT           ; load X with address of prompt
            movb  #$48, DSPSTART    ; set starting address for msg
            jsr   dispchar          ; branch to dispchar
            tst   MESSFIN           ; test messfin
            beq   t3s11skip         ; if message isn't done, skip
            clr   MESSFIN           ; reset MESSFIN
            clr   CLRF2_FLG         ; clear msg flag
            ldaa  #$48              ; load a with 49
            jsr   SETADDR           ; set cursor location for echo
t3s11skip:  rts

t3state12:                          ; echo                         
            ldx   #BUFFER           ; load X with the address of the first character in buffer
            ldaa  BUFFCOUNT         ; load a with the number of characters put in the buffer
            suba  #$01              ; subtract 1 from a so that count is the location of the last char
            ldab  A,X               ; load accumulator b with A + X
            jsr   OUTCHAR           ;
            clr   ECHO_FLG          ;
            movb  #$01, t3state     ; move to hub state
            rts                     ;
            
t3state13:                          ; error delay
            tstw  EDELCOUNT         ; test counter
            beq   t3s1done          ; skip delay if count is 0
            decw  EDELCOUNT         ; dec count
            rts
t3s1done:   clr   ERR_FLG           
            clr   EDEL_FLG
            movb  #$01, t3state     ; sends mastermind to display basic messages
            rts          

dispchar:                           ; code to display a message cooperatively        
            ldaa  DSPCOUNT          ; load A with DSPCOUNT
            tsta
            bne   skip              ; skip set start on all counts but first 
            ldaa  DSPSTART          ; load a with starting point
            jsr   SETADDR           ; set starting point
skip:   
            ldaa  DSPCOUNT          ; load accumulator A with DSPCOUNT
            ldab  A,X               ; load accumulator B with X + DSPCOUNT
            tstb                    ; test B for ascii null
            beq   done              ; branch to done if equal to 0
            jsr   OUTCHAR
            inc   DSPCOUNT          ; inc COUNT
            rts
done:   
            movb #$01, MESSFIN      ;set MESSFIN to 1
            movb #$01, t3state      ;hub state on next loop
            clr  DSPCOUNT
            rts 

;-------------------------------TASK_4 Pattern 1---------------------------------------

TASK_4:   ldaa  t4state                 ; get current t4state and branch accordingly
          beq   t4state0
          deca
          beq   t4state1
          deca
          beq   t4state2
          deca
          beq   t4state3
          deca
          beq   t4state4
          deca
          beq   t4state5
          deca
          lbeq  t4state6
          deca
          lbeq  t4state7
          rts                          ; undefined state - do nothing but return

t4state0:                              ; init TASK_4 (not G, not R)
          bclr  PORTP, LED_MSK_1       ; ensure that LEDs are off when initialized
          bset  DDRP, LED_MSK_1        ; set LED_MSK_1 pins as PORTS outputs
          movb  #$01, t4state          ; set next state  
          rts
          
t4state1:                   ; 
          tst   PAT1_ON
          beq   t4s1skip               ; if we don't want LED 1 on, then skip
          movb  #$02, t4state          ; set next state
t4s1skip:
          rts

t4state2:                              ; G,  not R
          tst   PAT1_ON
          beq   t4reset
          bset  PORTP, G_LED_1         ; set state1 pattern on LEDs
          tst   PAT1_DONE                 ; check TASK_4 done flag
          beq   exit_t4s2              ; if not done, return
          movb  #$03, t4state          ; if done, set next state
exit_t4s2:
          rts
 
t4state3:                              ; not G, not R
          tst   PAT1_ON
          beq   t4reset
          bclr  PORTP, G_LED_1         ; set state2 pattern on LEDs
          tst   PAT1_DONE              ; check TASK_4 done flag
          beq   exit_t4s3              ; if not done, return
          movb  #$04, t4state          ; if done, set next state
exit_t4s3:
          rts

 
t4state4:                              ; not G, R
          tst   PAT1_ON
          beq   t4reset
          bset  PORTP, R_LED_1         ; set state3 pattern on LEDs
          tst   PAT1_DONE              ; check TASK_4 done flag
          beq   exit_t4s4              ; if not done, return
          movb  #$05, t4state          ; if done, set next state
exit_t4s4: 
          rts

t4state5                               ; not G, not R
          tst   PAT1_ON
          beq   t4reset
          bclr  PORTP, R_LED_1         ; set state4 pattern on LEDs
          tst   PAT1_DONE              ; check TASK_4 done flag
          beq   exit_t4s5              ; if not done, return
          movb  #$06, t4state          ; if done, set next state
exit_t4s5:
          rts
 
 
t4state6:                              ; G, R
          tst   PAT1_ON
          beq   t4reset
          bset  PORTP, LED_MSK_1       ; set state5 pattern on LEDs
          tst   PAT1_DONE              ; check TASK_4 done flag
          beq   exit_t4s6              ; if not done, return
          movb  #$07, t4state          ; if done, set next state
exit_t4s6: 
          rts
                    
t4state7: 
          tst   PAT1_ON                ; not G, not R
          beq   t4reset
          bclr  PORTP, LED_MSK_1       ; set state6 pattern on LEDs
          tst   PAT1_DONE              ; check TASK_4 done flag
          beq   exit_t4s7              ; if not done, return
          movb  #$02, t4state          ; if done, set next state
exit_t4s7:
          rts                          ; exit TASK_4
          
          
t4reset:
          movb  #$00, t4state
          rts    


;-------------------------------TASK_5 Timing 1----------------------------------------

TASK_5:   
          ldaa  t5state                ; get current t2state and branch accordingly
          beq   t5state0
          deca
          beq   t5state1
          rts                          ; undefined state - do nothing but return
t5state0:                              ; initialization for TASK_2
          clr   PAT1_DONE
          clr   PAT1_COUNT
          movw  TICKS_1, PAT1_COUNT    ; initialize COUNT_1 to TICKS_1
          movb  #$01, t5state          ; set next state
          rts
t5state1:                              ; (re)initialize COUNT_1
          tst   PAT1_ON
          beq   exit_t5s1              ; skip if LED 1 isn't supposed to be on
          tst   PAT1_DONE              ; check for need to reinitialize
          beq   t5s1a                  ; no need to reintialize
          movw  TICKS_1, PAT1_COUNT    ; reinitialize COUNT_1 to TICKS_1
          clr   PAT1_DONE              ; clear DONE_1 after reinitializetion
t5s1a:    
          decw  PAT1_COUNT             ; decrement COUNT_1
          bne   exit_t5s1              ; if COUNT_1 is not zero, simply return
          movb  #$01, PAT1_DONE        ; if COUNT_1 is zero, set DONE_1 and return
exit_t5s1:
          rts                          ; exit TASK_2

;-------------------------------TASK_6 Pattern 2---------------------------------------

TASK_6:   ldaa  t6state                 ; get current t3state and branch accordingly
          beq   t6state0
          deca
          beq   t6state1
          deca
          beq   t6state2
          deca
          beq   t6state3
          deca
          beq   t6state4
          deca
          beq   t6state5
          deca
          beq   t6state6
          deca
          beq   t6state7
          rts
                                    ; undefined state - do nothing but return
 t6state0:                             ; init TASK_6 (not G, not R)
          bclr  PORTP, LED_MSK_2       ; ensure that LEDs are off when initialized
          bset  DDRP, LED_MSK_2        ; set LED_MSK_2 pins as PORTS outputs
          movb  #$01, t6state          ; set next state  
          rts
          
t6state1:                   ; 
          tst   PAT2_ON
          beq   t6s1skip               ; if we don't want LED 1 on, then skip
          movb  #$02, t6state          ; set next state
t6s1skip:
          rts

t6state2:                              ; G,  not R
          tst   PAT2_ON
          beq   t6reset
          bset  PORTP, G_LED_2         ; set state1 pattern on LEDs
          tst   PAT2_DONE                 ; check TASK_6 done flag
          beq   exit_t6s2              ; if not done, return
          movb  #$03, t6state          ; if done, set next state
exit_t6s2:
          rts
 
t6state3:                              ; not G, not R
          tst   PAT2_ON
          beq   t6reset
          bclr  PORTP, G_LED_2         ; set state2 pattern on LEDs
          tst   PAT2_DONE              ; check TASK_6 done flag
          beq   exit_t6s3              ; if not done, return
          movb  #$04, t6state          ; if done, set next state
exit_t6s3:
          rts

 
t6state4:                              ; not G, R
          tst   PAT2_ON
          beq   t6reset
          bset  PORTP, R_LED_2         ; set state3 pattern on LEDs
          tst   PAT2_DONE              ; check TASK_6 done flag
          beq   exit_t6s4              ; if not done, return
          movb  #$05, t6state          ; if done, set next state
exit_t6s4: 
          rts

t6state5                               ; not G, not R
          tst   PAT2_ON
          beq   t6reset
          bclr  PORTP, R_LED_2         ; set state4 pattern on LEDs
          tst   PAT2_DONE              ; check TASK_6 done flag
          beq   exit_t6s5              ; if not done, return
          movb  #$06, t6state          ; if done, set next state
exit_t6s5:
          rts
 
 
t6state6:                              ; G, R
          tst   PAT2_ON
          beq   t6reset
          bset  PORTP, LED_MSK_2       ; set state5 pattern on LEDs
          tst   PAT2_DONE              ; check TASK_6 done flag
          beq   exit_t6s6              ; if not done, return
          movb  #$07, t6state          ; if done, set next state
exit_t6s6: 
          rts
                    
t6state7: 
          tst   PAT2_ON                ; not G, not R
          beq   t6reset
          bclr  PORTP, LED_MSK_2       ; set state7 pattern on LEDs
          tst   PAT2_DONE              ; check TASK_6 done flag
          beq   exit_t6s7              ; if not done, return
          movb  #$02, t6state          ; if done, set next state
exit_t6s7:
          rts                          ; exit TASK_6
          
          
t6reset:
          movb  #$00, t6state
          rts    


;-------------------------------TASK_7 Timing 2----------------------------------------

TASK_7:   
          ldaa  t7state                ; get current t7state and branch accordingly
          beq   t7state0
          deca
          beq   t7state1
          rts                          ; undefined state - do nothing but return
t7state0:                              ; initialization for TASK_7
          clr   PAT2_DONE
          clr   PAT2_COUNT
          movw  TICKS_2, PAT2_COUNT    ; initialize COUNT_2 to TICKS_2
          movb  #$01, t7state          ; set next state
          rts
t7state1:                              ; (re)initialize COUNT_2
          tst   PAT2_ON
          beq   exit_t7s1              ; skip if LED 2 isn't supposed to be on
          tst   PAT2_DONE              ; check for need to reinitialize
          beq   t7s1a                  ; no need to reintialize
          movw  TICKS_2, PAT2_COUNT    ; reinitialize COUNT_2 to TICKS_2
          clr   PAT2_DONE              ; clear DONE_2 after reinitializetion
t7s1a:    
          decw  PAT2_COUNT             ; decrement COUNT_2
          bne   exit_t7s1              ; if COUNT_2 is not zero, simply return
          movb  #$01, PAT2_DONE        ; if COUNT_2 is zero, set DONE_1 and return
exit_t7s1:
          rts                      ; exit TASK_7
          
;-------------------------------TASK_8 Delay-------------------------------------------

TASK_8:   ldaa  t8state                ; get current t8state and branch accordingly
          beq   t8state0
          deca
          beq   t8state1
          rts                          ; undefined state - do nothing but return
t8state0:                              ; initialization for TASK_8
                                       ; no initialization required
          movb  #$01, t8state          ; set next state
          rts
t8state1:
 
          jsr   DELAY_1ms
          rts                          ; exit TASK_8

DELAY_1ms:                             ; Delay task to be repeated as many times as needed
          ldy   #$0584
INNER:                                 ; inside loop
          cpy   #0
          beq   EXIT
          dey
          bra   INNER
EXIT:
          rts                          ; exit DELAY_1ms

;/------------------------------------------------------------------------------------\
;| Subroutines                                                                        |
;\------------------------------------------------------------------------------------/
ASC_BIN:                               
CLP:      ldd   BIN_RES                ; load RESULT address into D
          ldy   #$0A                   ; load 10 into y
          emul                         ; whats in y, mult by D, store in Y concat w/ D
          tsty                         ; check if aything in Y, if yes, there is an error
          bne   TDB                    ; branch if too big
          std   BIN_RES                ; store D in result
          ldaa  TEMP                   ; load TEMP into a
          ldab  A, X                   ; load into B, A + X
          subb  #$30                   ; subtract $30 from D
          ldaa  #$00                   ; remove temp from mathematics
          addd  BIN_RES                ; add RESULT to D
          bcs   TDB                    ; check carry flag and branch if necessary
          std   BIN_RES                ; store D in RESULT
          inc   TEMP                   ; increment TEMP
          dec   BUFFCOUNT              ; decrement count
          bne   CLP                    ; branch to CLP and repeat if COUNT is not 0
          cpd   #$00                   ; compare double accumulator d (holds result) to 0
          beq   ZERO                   ; if 0 , branch to error
          clr   TEMP                   ; clear temp for next time
          ldaa  #$00                   ; clear any possible errenous a value
          rts

TDB:      
          ldaa   #$01        
          clr    TEMP                  ; clear temp for next time
          rts                          ; rts to main

ZERO:     
          ldaa   #$02 
          clr    TEMP                  ; clear temp for next time
          rts                          ; rts to main

;/------------------------------------------------------------------------------------\
;| ASCII Messages and Constant Data                                                   |
;\------------------------------------------------------------------------------------/
; Any constants can be defined here

T1MESS    DC.B  'TIME1 =',$00                              ; Time 1 message
T2MESS    DC.B  'TIME2 =',$00                              ; Time 2 message
F1MESS    DC.B  '<F1> to update LED1 period', $00          ; F1 message
F2MESS    DC.B  '<F2> to update LED2 period', $00          ; F2 message
PROMPT    DC.B  '      ENTER LED PERIOD...       ', $00    ; Prompt message  
ERROR1    DC.B  '      MAGNITUDE TOO LARGE       ', $00    ; Error 1 message
ERROR2    DC.B  '      NO DIGITS ENTERED         ', $00    ; Error 2 message
ERROR3    DC.B  '      ZERO IS NOT A VALID INPUT ', $00    ; Error 3 message


;/------------------------------------------------------------------------------------\
;| Vectors                                                                            |
;\------------------------------------------------------------------------------------/
; Add interrupt and reset vectors here

        ORG   $FFFE                    ; reset vector address
        DC.W  Entry
        ORG   $FFCE                    ; Key Wakeup interrupt vector address [Port J]
        DC.W  ISR_KEYPAD
