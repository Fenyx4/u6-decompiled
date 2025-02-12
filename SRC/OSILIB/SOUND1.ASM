INCLUDE OSI.INC
INCLUDE SOUND.INC

DSegStart
delayCntH	dw 0	;D_308C
delayCntL	dw 0	;D_308E
D_3090	dw 0
DSegEnd

CSegStart	SEG_33CD_TEXT

ProcStart	OSI_playWavedNote	;C_33CD_0006
	MOV	AX,D_2FC6
	CMP	AX,100
	JGE	C_0018
	XOR	AX,AX
	JZ	C_001D
C_0018:	MOV	CL,24
	DIV	CL
	CBW
C_001D:	MOV	D_3090,AX
	;--
	MOV	AX,3Ch
	OUT_42_AX
	;--
	MOV	BX,[BP+08]
	MOV	CX,[BP+0Ah]
	XOR	DX,DX
	CMP	BYTE PTR SoundFlag,0
	JNZ	C_0065
C_0038:	;--
	MOV	AX,[BP+0Eh]
	ADD	DX,AX
	PUSH	AX
	PUSH	CX
	ADD	BX,[BP+06]
	;-- tempo --
	MOV	AX,D_3090
	OR	AX,AX
	JZ	C_005F
	MOV	CX,[BP+0Ch]
	DELAY_CXAX
C_005F:	;--
	POP	CX
	POP	AX
	LOOP	C_0038
	;-- --
	JCXZ	C_00A8	;return
C_0065:	;-- --
	MOV	AX,[BP+0Eh]
	ADD	DX,AX
	PUSH	AX
	PUSH	CX
	CMP	DX,BX
	JA	C_0078
	;--
	SOUND_OFF
	;--
	JMP	SHORT C_007E
C_0078:	;--
	SOUND_ON
C_007E:	;--
	ADD	BX,[BP+06]
	;-- tempo --
	MOV	AX,D_3090
	OR	AX,AX
	JZ	C_009E
	MOV	CX,[BP+0Ch]
	DELAY_CXAX
C_009E:	;--
	POP	CX
	POP	AX
	LOOP	C_0065
	;--
	SOUND_OFF
C_00A8:	;--
ProcEndN	OSI_playWavedNote,0Ah

CSegEnd	SEG_33CD_TEXT

END
