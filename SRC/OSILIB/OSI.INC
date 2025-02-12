DSegStart	MACRO
_DATA	SEGMENT PUBLIC WORD 'DATA'
ENDM

DSegEnd	MACRO
_DATA	ENDS
ENDM

DGROUP	GROUP _DATA

DSegStart
DSegEnd


CSegStart	MACRO segName
segName	SEGMENT PUBLIC WORD 'CODE'
	ASSUME CS:segName,DS:DGROUP
ENDM

CSegEnd	MACRO segName
segName	ENDS
ENDM

ProcStart	MACRO procName
PUBLIC procName
procName	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
	PUSH	DS
ENDM

ProcRet	MACRO
	POP	DS
	POP	DI
	POP	SI
	POP	BP
	RET
ENDM

ProcEnd	MACRO	procName
	ProcRet
procName	ENDP
ENDM

ProcEndN	MACRO	procName,n
	POP	DS
	POP	DI
	POP	SI
	POP	BP
	RET	n
procName	ENDP
ENDM
