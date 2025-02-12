INCLUDE OSI.INC

EXTRN D_2FC6:WORD	;computer speed

DSegStart	
	
D_305A	dw 0
D_305C	dw 0
D_305E	dw 0,0	;original int 1Ch

DSegEnd


CSegStart	_DELAY_TEXT

ProcStart	OSI_delay	;33BB:0002
	MOV	AX,[BP+06]
	MOV	D_305C,AX
C_000E:	;--
	MOV	AX,D_305A
	CMP	AX,D_305C
	JB	C_000E
	;--
	MOV	D_305A,0
ProcEndN	OSI_delay,2


NEW_INT_1C:	;33BB:0024
	STI
	PUSH	DS
	PUSH	AX
	PUSH	SI
	;--
	MOV	AX,DGROUP
	MOV	DS,AX
	MOV	SI,OFFSET DGROUP:D_305A
	INC	WORD PTR [SI]
	;--
	POP	SI
	POP	AX
	POP	DS
	IRET

PUBLIC OSI_delay_init	;33BB:0036
OSI_delay_init	PROC FAR
	PUSH	SI
	PUSH	DI
	PUSH	DS
	;--
	MOV	D_305A,0
	;--
	PUSH	ES
	MOV	AL,1Ch
	MOV	AH,35h
	INT	21h
	MOV	AX,ES
	POP	ES
	MOV	D_305E,BX
	MOV	D_305E+2,AX
	;--
	PUSH	DS
	PUSH	CS
	POP	DS
	LEA	DX,NEW_INT_1C
	MOV	AL,1Ch
	MOV	AH,25h
	INT	21h
	POP	DS
	;--
	POP	DS
	POP	DI
	POP	SI
	RET
OSI_delay_init	ENDP

PUBLIC OSI_delay_clean	;33BB:0062
OSI_delay_clean	PROC FAR
	PUSH	SI
	PUSH	DI
	PUSH	DS
	;--
	MOV	AX,D_305E+2
	MOV	DX,D_305E
	PUSH	DS
	MOV	DS,AX
	MOV	AL,1Ch
	MOV	AH,25h
	INT	21h
	POP	DS
	;--
	POP	DS
	POP	DI
	POP	SI
	RET
OSI_delay_clean	ENDP

CSegEnd	_DELAY_TEXT

END
