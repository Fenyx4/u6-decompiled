INCLUDE OSI.INC

;emulate a far call
MY_CALL	MACRO s,o
	db 9Ah
	dw o,s
ENDM

DSegStart

PUBLIC D_032E,D_0332,D_0334,D_0336

D_032E	dw OSI_callback,SEG OSI_callback
D_0332	dw 0	;error code
D_0334	dw 0	;error origin
D_0336	dw 0	;last filename

DSegEnd

OSIERR_CB	MACRO fctNum,errNum
	MOV	DS,CS:C_0207
	MOV	D_0332,errNum
	MOV	D_0334,fctNum
	CALL	DWORD PTR D_032E
ENDM


OSIERR_1	MACRO errNum,retry
	LOCAL _skip_,_noErr_

	JNB	_noErr_
	PUSH	DS
	OSIERR_CB	errNum,AX
	TEST	D_0332,0FFFFh
	POP	DS
	JZ	retry
	MOV	AX,-1
	STC
_noErr_:
ENDM

OSIERR_2	MACRO errNum,retry
	LOCAL _skip_,_noErr_

	JNB	_noErr_

	OSIERR_CB	errNum,AX
	TEST	D_0332,0FFFFh

	JZ	retry


_noErr_:
ENDM


_TEXT	SEGMENT PUBLIC BYTE 'CODE'
	ASSUME CS:_TEXT,DS:DGROUP

C_0207	dw DGROUP	;35BD

PUBLIC OSI_callback
OSI_callback	PROC FAR
	RET
OSI_callback	ENDP


PUBLIC OSI_open
OSI_open	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
	;--
	MOV	ES,CS:C_0207
C_0214:
	MOV	DX,[BP+06]
	MOV	ES:D_0336,DX
	;--
	MOV	AX,(3Dh SHL 8) OR 2	;open file
	INT	21h
	;--
	OSIERR_1	1,C_0214
	;--
	POP	DI
	POP	SI
	POP	BP
	RET	2
OSI_open	ENDP


PUBLIC OSI_close
OSI_close	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
C_024E:	;--
	MOV	BX,[BP+06]
	MOV	AH,3Eh	;close file
	INT	21h
	;--
	OSIERR_1	2,C_024E
	;--
	POP	DI
	POP	SI
	POP	BP
	RET	2
OSI_close	ENDP


PUBLIC OSI_create
OSI_create	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
	;--
	MOV	DX,DGROUP
	MOV	ES,DX
C_0287:
	MOV	AH,3Ch	;create file
	XOR	CX,CX
	MOV	DX,[BP+06]
	MOV	ES:D_0336,DX
	INT	21h
	;--
	OSIERR_1	3,C_0287
	;--
	POP	DI
	POP	SI
	POP	BP
	RET	2
OSI_create	ENDP


PUBLIC OSI_delete
OSI_delete	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
	;--
	MOV	DX,DGROUP
	MOV	ES,DX
C_02C7:
	MOV	AH,41h	;delete file
	MOV	DX,[BP+06]
	MOV	ES:D_0336,DX
	INT	21h
	;--
	OSIERR_1	4,C_02C7
	;--
	POP	DI
	POP	SI
	POP	BP
	RET	2
OSI_delete	ENDP


PUBLIC OSI_read
OSI_read	PROC FAR
	PUSH	BP
	MOV	BP,SP
	SUB	SP,4
	PUSH	SI
	PUSH	DI
	PUSH	DS
	;--
	MOV	WORD PTR [BP-04],0
	MOV	WORD PTR [BP-02],0
	MOV	BX,[BP+12h]
	MOV	CX,[BP+10h]
	OR	CX,CX
	JL	C_0337
	MOV	DX,[BP+0Eh]
	MOV	AX,(42h SHL 8) OR 0	;move file pointer
	INT	21h
	JNB	C_0337
	OSIERR_CB	5,AX
	JMP	C_03D2
C_0337:	;--
	TEST	WORD PTR [BP+0Ch],0FFFFh
	JNZ	C_0344
	CMP	WORD PTR [BP+0Ah],0FFF0h
	JBE	C_0388
C_0344:	;--
	MOV	AH,3Fh	;read file
	MOV	BX,[BP+12h]
	MOV	CX,0FFF0h
	LDS	DX,[BP+06]
	INT	21h
	;--
	OSIERR_2	5,C_0344
	;--
	ADD	[BP-04],AX
	ADC	WORD PTR [BP-02],0
	CMP	AX,0FFF0h
	JNZ	C_03BD
	SUB	WORD PTR [BP+0Ah],0FFF0h
	SBB	WORD PTR [BP+0Ch],0
	ADD	WORD PTR [BP+08],0FFFh
	JMP	C_0337
C_0388:	;--
	MOV	AH,3Fh	;read file
	MOV	BX,[BP+12h]
	MOV	CX,[BP+0Ah]
	LDS	DX,[BP+06]
	INT	21h
	;--
	OSIERR_2	5,C_0388
	;--
	ADD	[BP-04],AX
	ADC	WORD PTR [BP-02],0
	CMP	AX,[BP+0Ah]
	JZ	C_03D2
C_03BD:
	OSIERR_CB	5,-1
C_03D2:	;--
	MOV	AX,[BP-04]
	MOV	DX,[BP-02]
	;--
	POP	DS
	POP	DI
	POP	SI
	MOV	SP,BP
	POP	BP
	RET	0Eh
OSI_read	ENDP


PUBLIC OSI_write
OSI_write	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
	PUSH	DS
	;--
	MOV	BX,[BP+12h]
	MOV	CX,[BP+10h]
	OR	CX,CX
	JL	C_0410
	MOV	DX,[BP+0Eh]
	MOV	AX,(42h SHL 8) OR 0	;move file pointer
	INT	21h
	JNB	C_0410
	OSIERR_CB	6,AX
	JMP	C_049D
C_0410:	;--
	TEST	WORD PTR [BP+0Ch],0FFFFh
	JNZ	C_041D
	CMP	WORD PTR [BP+0Ah],0FFF0h
	JBE	C_045A
C_041D:
	MOV	AH,40h	;write file
	MOV	BX,[BP+12h]
	MOV	CX,0FFF0h
	LDS	DX,[BP+06]
	INT	21h
	;--
	OSIERR_2	6,C_041D
	;--
	CMP	AX,0FFF0h
	JNZ	C_0488
	SUB	WORD PTR [BP+0Ah],0FFF0h
	SBB	WORD PTR [BP+0Ch],0
	ADD	WORD PTR [BP+08],0FFFh
	JMP	C_0410
C_045A:	;--
	MOV	AH,40h	;write file
	MOV	BX,[BP+12h]
	MOV	CX,[BP+0Ah]
	LDS	DX,[BP+06]
	INT	21h
	;--
	OSIERR_2	6,C_045A
	;--
	CMP	AX,[BP+0Ah]
	JZ	C_049D
C_0488:
	OSIERR_CB	6,-1
C_049D:	;--
	POP	DS
	POP	DI
	POP	SI
	MOV	SP,BP
	POP	BP
	RET	0Eh
OSI_write	ENDP


PUBLIC OSI_rename
OSI_rename	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
C_04AB:	;--
	MOV	AH,56h
	MOV	ES,CS:C_0207
	MOV	DX,[BP+08]
	MOV	ES:D_0336,DX
	MOV	DI,DS
	MOV	ES,DI
	MOV	DI,[BP+06]
	INT	21h
	;--
	OSIERR_1	7,C_04AB
	;--
	POP	DI
	POP	SI
	POP	BP
	RET	4
OSI_rename	ENDP

PUBLIC OSI_copy
OSI_copy	PROC FAR
	PUSH	BP
	MOV	BP,SP
	SUB	SP,0Eh
	PUSH	SI
	PUSH	DI
	PUSH	DS
	;--
	MOV	AH,48h	;allocate memory
	MOV	BX,0FFFFh
	INT	21h
	JNB	C_0540
	CMP	AX,8
	JNZ	C_0540
	MOV	[BP-06],BX
	;--
	MOV	AH,48h	;allocate memory
	INT	21h
	JB	C_0540
	MOV	[BP-02],AX
	;--
	MOV	AX,[BP-06]
	MOV	CL,4
	ROL	AX,CL
	MOV	[BP-06],AX
	;--
	AND	WORD PTR [BP-06],NOT 0Fh
	AND	AX,0Fh
	MOV	[BP-04],AX
	;--
	MOV	AX,[BP+08]                         
	PUSH	AX
	MY_CALL	_TEXT,OSI_open
	JB	C_0540
	MOV	[BP-0Ch],AX
	;--
	MOV	AH,3Ch	;create file
	XOR	CX,CX
	MOV	DX,[BP+06]
	INT	21h
	JB	C_0540
	MOV	[BP-0Eh],AX
	;--
	JMP	SHORT C_055B
C_0540:
	OSIERR_CB	8,AX
	MOV	AH,49h	;free memory
	MOV	ES,[BP-02]
	INT	21h
	;--
	JMP	SHORT C_05D8
C_055B:	;--
	MOV	AX,[BP-0Ch]
	PUSH	AX
	MOV	AX,0FFFFh
	PUSH	AX
	PUSH	AX
	MOV	AX,[BP-04]
	PUSH	AX
	MOV	AX,[BP-06]
	PUSH	AX
	MOV	AX,[BP-02]
	PUSH	AX
	XOR	AX,AX
	PUSH	AX
	MY_CALL	_TEXT,OSI_read
	MOV	[BP-0Ah],AX
	MOV	[BP-08],DX
	;--
	MOV	AX,[BP-0Eh]
	PUSH	AX
	MOV	AX,0FFFFh
	PUSH	AX
	PUSH	AX
	MOV	AX,[BP-08]
	PUSH	AX
	MOV	AX,[BP-0Ah]
	PUSH	AX
	MOV	AX,[BP-02]
	PUSH	AX
	XOR	AX,AX
	PUSH	AX
	MY_CALL	_TEXT,OSI_write
	;--
	MOV	AX,[BP-08]
	CMP	AX,[BP-04]
	JB	C_05AB
	;--
	MOV	AX,[BP-0Ah]
	CMP	AX,[BP-06]
	JNB	C_055B
C_05AB:	;--
	MOV	AX,[BP-0Ch]
	PUSH	AX
	MY_CALL	_TEXT,OSI_close
	;--
	MOV	AX,[BP-0Eh]
	PUSH	AX
	MY_CALL	_TEXT,OSI_close
	;--
	MOV	AH,49h	;free memory
	MOV	ES,[BP-02]
	INT	21h
	JNB	C_05D8
	OSIERR_CB	8,AX
C_05D8:	;--
	POP	DS
	POP	DI
	POP	SI
	MOV	SP,BP
	POP	BP
	RET	4
OSI_copy	ENDP


PUBLIC OSI_fileSize
OSI_fileSize	PROC FAR
	PUSH	BP
	MOV	BP,SP
	PUSH	SI
	PUSH	DI
	;--
	MOV	BX,[BP+06]
	MOV	AX,(42h SHL 8) OR 2	;move file pointer(seek_end)
	XOR	CX,CX
	MOV	DX,CX
	INT	21h
	JNB	C_05F8
	;--
	XOR	AX,AX
	MOV	DX,AX
C_05F8:	;--
	POP	DI
	POP	SI
	POP	BP
	RET	2
OSI_fileSize	ENDP


PUBLIC OSI_memory
OSI_memory	PROC FAR
	PUSH	BP
	PUSH	SI
	PUSH	DI
	PUSH	DS
	;--
	MOV	AH,48h	;allocate memory
	MOV	BX,0FFFFh
	INT	21h
	JNB	C_0624
	CMP	AX,8
	JNZ	C_0624
	MOV	AX,BX
	ROL	AX,1
	ROL	AX,1
	ROL	AX,1
	ROL	AX,1
	MOV	DX,AX
	AND	AX,NOT 0Fh
	AND	DX,0Fh
	JMP	SHORT C_0628
C_0624:	;--
	XOR	AX,AX
	XOR	DX,DX
C_0628:	;--
	POP	DS
	POP	DI
	POP	SI
	POP	BP
	RET
OSI_memory	ENDP

_TEXT	ENDS

END
