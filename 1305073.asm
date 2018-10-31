.Model Small
.Stack 100h
.DATA
S DW 0
C DW 0
T1 DW 0
T2 DW 0
CR1 DW 10
CC1 DW 40
CR2 DW 75
CC2 DW 160
CR3 DW 140 
CC3 DW 280
CR4 DW 140
CC4 DW 150
T DW 0
N DB 'X'
C1 DB 19
TEMP DW 0
TEMP1 DW 0
.Code


SET_MOOD PROC
; set EGA 320x200 256 color mode
    MOV AH, 0h
    MOV AL, 0dh
    INT 10h
    RET
SET_MOOD ENDP
 

DRAW_BOUNDARY PROC
;INPUT DX ROW
    MOV AH,0CH
    MOV AL,4
    MOV BH,0
    MOV CX,0
LOOP1:
    INT 10H
    INC CX
    CMP CX,319
    JL LOOP1
    RET
DRAW_BOUNDARY ENDP

 
DRAW_CAR PROC
     MOV AH, 0CH ; write pixel function
;INPUTS
;    MOV AL, pixel color 
;   MOV BH,page 
;    MOV DX,row 
;MOV CX,COLUMN
    PUSH CX
    PUSH DX
    ADD CX,40 ;CAR LENGTH
    ADD DX,30 ;CAR HEIGHT
    MOV T1,CX
    MOV T2,DX
    POP DX
    POP CX
    MOV C,CX
OL1:    MOV CX,C  ; col
L1: INT 10h
    ;INC AL  ; next color
    INC CX  ; next col
    CMP CX, T1
    JL L1
    INC DX; next row
    CMP DX, T2
    JL OL1
    RET
DRAW_CAR ENDP

DELAY PROC
    MOV CX,00H
    MOV DX,060H
    MOV AH,86H
    INT 15H
DELAY ENDP


MAIN PROC   
    MOV AX,@DATA
    MOV DS,AX

    CALL SET_MOOD
    MOV DX,65

    CALL DRAW_BOUNDARY
    MOV DX,130
    CALL DRAW_BOUNDARY
TOP:
    ;DRAW CAR1
    MOV AL,15
    MOV BH,0
    MOV DX,CR1
    MOV CX,CC1
    CALL DRAW_CAR
    ;DRAW CAR2
    MOV AL,15
    MOV BH,0
    MOV DX,CR2
    MOV CX,CC2
    CALL DRAW_CAR
    ;DRAW CAR3
    MOV AL,15
    MOV BH,0
    MOV DX,CR3
    MOV CX,CC3
    CALL DRAW_CAR
    ;DRAW CAR4
    MOV AL,1
    MOV BH,0
    MOV DX,CR4
    MOV CX,CC4
    CALL DRAW_CAR
    ;ERASE CAR1
    MOV AL,0
    MOV BH,0
    MOV DX,CR1
    MOV CX,CC1
    CALL DRAW_CAR
    ;ERASE CAR2
    MOV AL,0
    MOV BH,0
    MOV DX,CR2
    MOV CX,CC2
    CALL DRAW_CAR
    ;ERASE CAR3
    MOV AL,0
    MOV BH,0
    MOV DX,CR3
    MOV CX,CC3
    CALL DRAW_CAR
    ;ERASE CAR4
    MOV AL,0
    MOV BH,0
    MOV DX,CR4
    MOV CX,CC4
    CALL DRAW_CAR
    
    ;MOV CAR1
    MOV BX,CC1
    SUB BX,2
    MOV CC1,BX
    CMP BX,0
    JGE W1
    MOV BX,320
    MOV CC1,BX    
W1:
    ;MOV CAR2
    MOV BX,CC2
    SUB BX,2
    MOV CC2,BX
    CMP BX,0
    JGE W2
    MOV BX,320
    MOV CC2,BX
W2:
    ;MOV CAR3
    MOV BX,CC3
    SUB BX,2
    MOV CC3,BX
    CMP BX,0
    JGE W3
    MOV BX,320
    MOV CC3,BX
W3:  
    MOV AH,06H
    MOV DL,0FFH
    INT 21H
    JZ SES
    CMP AL,48H
    JNE W4
    MOV BX,CR4
    CMP BX,10
    JLE W4 
    SUB BX,65
    MOV CR4,BX
    JMP SES
W4: 
    ;MOVE CAR4
    CMP AL,50H
    JNE SES
    MOV BX,CR4
    CMP BX,140
    JGE SES
    ADD BX,65
    MOV CR4,BX
SES:
    ;CHECK IF GAME OVER
    MOV BX,CR4
    CMP BX,10
    JE LANE1
    CMP BX,75
    JE LANE2
    JMP LANE3
LANE1:
    MOV BX,CC4
    SUB BX,CC1
    CMP BX,30
    JG OK
    CMP BX,-30D
    JL OK
    JMP OVER
LANE2:
    MOV BX,CC4
    SUB BX,CC2
    CMP BX,30
    JG OK
    CMP BX,-30D
    JL OK
    JMP OVER
LANE3:
    MOV BX,CC4
    SUB BX,CC3
    CMP BX,30
    JG OK
    CMP BX,-30D
    JL OK
    JMP OVER    
OK: 
    ;UPDATE SCORE
    MOV BX,CC1
    CMP BX,0
    JLE SCORE
    MOV BX,CC2
    CMP BX,0
    JLE SCORE
    MOV BX,CC3
    CMP BX,0
    JLE SCORE
    JMP NO_SCORE
SCORE:
    INC S
NO_SCORE:   
    JMP TOP
OVER:
    ;PUSH SCORE IN STACK
    XOR CX,CX
    MOV BX,10
    MOV AX,S
W5:
    XOR DX,DX
    DIV BX
    PUSH DX
    INC CX
    OR AX,AX
    JNE W5
    
    MOV TEMP,CX ; NUMBER OF DIGITS IN S
; set graphics mode 4
    MOV AH,0h
    MOV AL,4h
    INT 10h
; set bgd color to cyan
    MOV AH, 0BH
    MOV BH, 00h
    MOV BL, 3
    INT 10h
; select palette 0
    MOV BH, 1
    MOV BL, 0
    INT 10h
    W7:
; move cursor to page 0, row 12, col 19
        MOV AH, 02
        MOV BH, 0
        MOV DH, 12
        MOV DL, C1
        INT 10h
; write char        
        ;MOV AH, 9
        ;MOV AL,N
        POP AX
        ADD AL,'0'
        MOV AH,9
        MOV BL, 2 ; color value from palette
        MOV CX, 1
        INT 10h
        INC C1
        ;INC N
        INC TEMP1
        MOV BX,TEMP1
        CMP BX,TEMP
    JL W7  
        
; getch     
        MOV AH, 0
        INT 16h
; return to text mode
        MOV AX, 3
        INT 10h
        
; return to dos
        MOV AH, 4CH
        INT 21h
main EndP
     End main
    
    
    