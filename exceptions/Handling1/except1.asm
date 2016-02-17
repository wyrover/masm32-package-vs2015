; seh.asm by samael Structured exception handling
;
.386
.model flat,stdcall
option casemap:none


include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc

include \masm32\include\comctl32.inc
include \masm32\include\gdi32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\masm32.lib

FinalExceptionHandler                 proto :dword

.data

szPTEHMessage	db "I'm displayed from SafeOffset, because an exception occured inside the area guarded by the Per-Thread Exception Handler...",0
szPTEHCaption	db "Per-thread EH",0

szFEHMessage	db "I'm displayed against all odds, tearing my way through bad code... ;)",0
szFEHCaption	db "Y-e-e-e-e-h-a !!!",0

.code

EntryPoint:

        ;Install Universal (Final) EH.
        invoke SetUnhandledExceptionFilter, offset FinalExceptionHandler
        ;Install per-thread EH
		assume	FS:nothing					; We use the ASSUME FS:NOTHING directive because MASM by default
											; assumes the use of FS register to ERROR
		push	offset PTExceptionHandler
        push	FS:[0]
		mov		FS:[0], esp

		; The code between installation and de-installation of the Per-Thread Exception
		; Handler is guarded by the handler.If exception occurs anywhere inside the guarded area,
		; we will go to the SafeOffset.
		; Cause an exception by writing to a forbidden address in order to activate the per-thread EH
		; The program flow will be redirected to SafeOffset

        xor		eax, eax
        mov		dword ptr [EAX], EAX		; cause an Exception Access Violation

		

@UninstallPerThreadSEH:

        ; Uninstall per-thread Eexception Handler

        pop		FS:[0]
        add		ESP, 4

		; Having uninstalled the Per-Thread Exception Handler, the code below is guarded by the
		; "final" handler.
		; Note that we could setup the "final" handler, to do an attempt to continue executing
		; the program, rather than just terminating it...


    ; Cause more exceptions in order to activate the  Universal (Final) EH.

        ;CLI         ;Lets execute a privilaged instruction.. Instruction length == 1
             ; [This instruction is going ot be patched to NOP by the Final Exception Handler]
        ;INT 3         ;Lets cause a breakpoint exception.. Instruction length == 1
             ; [This instruction is going ot be patched to NOP by the Final Exception Handler]
        ;CLI         ;Lets execute a privilaged instruction.. Instruction length == 1
             ; [This instruction is going ot be patched to NOP by the Final Exception Handler]
        INT 3         ;Lets cause a breakpoint exception.. Instruction length == 1
             ; [This instruction is going ot be patched to NOP by the Final Exception Handler]

		 ; cause Division By Zero Exception
		;xor eax, eax
		;xor edx, edx
		;div eax


_continue:
        ;Will this part ever be executed ?


        INVOKE MessageBox, NULL, ADDR szFEHMessage, ADDR szFEHCaption,MB_OK
        INVOKE ExitProcess,NULL


PTExceptionHandler proc C pExcept:DWORD, pFrame:DWORD, pContext:DWORD,
pDispatch:DWORD
        MOV EAX, pContext
        MOV [EAX].CONTEXT.regEip, OFFSET SafeOffset
      MOV EAX,ExceptionContinueExecution
      RET
PTExceptionHandler endp



FinalExceptionHandler proc lpExceptionInfo:DWORD

LOCAL dwExceptionAddress        : DWORD
LOCAL dwExceptionCode                : DWORD

.CONST

LINE_BREAK                                 EQU 0Dh,0Ah
DEFAULT_BUFFER_SIZE                 EQU 1024

.DATA
szErrorCaption           DB         "Universal (Final) EH",0
szErrorMessage           DB         "Cannot continue the normal execution of this program.",LINE_BREAK,\
                                "An exception was generated at address 0x%0.8lX.",LINE_BREAK,\
                                "Exception type: %s.",LINE_BREAK,\
                                "This application will now terminate.",LINE_BREAK,LINE_BREAK,\
                                "Or perhaps not... ;)",0

szACCESS_VIOLATION                 DB "EXCEPTION_ACCESS_VIOLATION",0
szARRAY_BOUNDS_EXCEEDED         DB "EXCEPTION_ARRAY_BOUNDS_EXCEEDED",0
szBREAKPOINT                         DB "EXCEPTION_BREAKPOINT",0
szDATATYPE_MISALIGNMENT         DB "EXCEPTION_DATATYPE_MISALIGNMENT",0
szFLT_DENORMAL_OPERAND                 DB "EXCEPTION_FLT_DENORMAL_OPERAND",0
szFLT_DIVIDE_BY_ZERO                  DB "EXCEPTION_FLT_DIVIDE_BY_ZERO",0
szFLT_INEXACT_RESULT                  DB "EXCEPTION_FLT_INEXACT_RESULT",0
szFLT_INVALID_OPERATION         DB "EXCEPTION_FLT_INVALID_OPERATION",0
szFLT_OVERFLOW                          DB "EXCEPTION_FLT_OVERFLOW",0
szFLT_STACK_CHECK                  DB "EXCEPTION_FLT_STACK_CHECK",0
szFLT_UNDERFLOW                         DB "EXCEPTION_FLT_UNDERFLOW",0
szILLEGAL_INSTRUCTION                  DB "EXCEPTION_ILLEGAL_INSTRUCTION",0
szIN_PAGE_ERROR                         DB "EXCEPTION_IN_PAGE_ERROR",0
szINT_DIVIDE_BY_ZERO                  DB "EXCEPTION_INT_DIVIDE_BY_ZERO",0
szINT_OVERFLOW                          DB "EXCEPTION_INT_OVERFLOW",0
szINVALID_DISPOSITION                 DB "EXCEPTION_INVALID_DISPOSITION",0
szNONCONTINUABLE_EXCEPTION         DB "EXCEPTION_NONCONTINUABLE_EXCEPTION",0
szPRIV_INSTRUCTION                  DB "EXCEPTION_PRIV_INSTRUCTION",0
szSINGLE_STEP                          DB "EXCEPTION_SINGLE_STEP",0
szSTACK_OVERFLOW                  DB "EXCEPTION_STACK_OVERFLOW",0
szUNKNOWN_EXCEPTION                DB "EXCEPTION_UNKNOWN_EXCEPTION",0

.DATA?

hHeap                        HANDLE ?
pBuffer                LPVOID ?
dwPreviousProtect        DWORD ?

.CODE
        PUSHAD
        INVOKE GetProcessHeap
        MOV hHeap, EAX
        INVOKE HeapAlloc, hHeap , HEAP_ZERO_MEMORY, DEFAULT_BUFFER_SIZE
        MOV pBuffer,EAX
        MOV EAX, [lpExceptionInfo]
        MOV EAX, [EAX]                      ;#2 lpEXCEPTION_RECORD
        MOV edi, [EAX+12]                         ;#3 ExceptionAddress;
        MOV dwExceptionAddress,edi
        MOV edi, [EAX]                         ;#2 ExceptionCode
        MOV dwExceptionCode,edi

        .if dwExceptionCode == EXCEPTION_ACCESS_VIOLATION
                MOV ESI, OFFSET szACCESS_VIOLATION
        .ELSEIF dwExceptionCode == EXCEPTION_ARRAY_BOUNDS_EXCEEDED
                MOV ESI, OFFSET szARRAY_BOUNDS_EXCEEDED
        .ELSEIF dwExceptionCode == EXCEPTION_BREAKPOINT
                MOV ESI, OFFSET szBREAKPOINT
        .ELSEIF dwExceptionCode == EXCEPTION_DATATYPE_MISALIGNMENT
                MOV ESI, OFFSET szDATATYPE_MISALIGNMENT
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_DENORMAL_OPERAND
                MOV ESI, OFFSET szFLT_DENORMAL_OPERAND
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_DIVIDE_BY_ZERO
                MOV ESI, OFFSET szFLT_DIVIDE_BY_ZERO
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_INEXACT_RESULT
                MOV ESI, OFFSET szFLT_INEXACT_RESULT
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_INVALID_OPERATION
                MOV ESI, OFFSET szFLT_INVALID_OPERATION
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_OVERFLOW
                MOV ESI, OFFSET szFLT_OVERFLOW
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_STACK_CHECK
                MOV ESI, OFFSET szFLT_STACK_CHECK
        .ELSEIF dwExceptionCode == EXCEPTION_FLT_UNDERFLOW
                MOV ESI, OFFSET szFLT_UNDERFLOW
        .ELSEIF dwExceptionCode == EXCEPTION_ILLEGAL_INSTRUCTION
                MOV ESI, OFFSET szILLEGAL_INSTRUCTION
        .ELSEIF dwExceptionCode == EXCEPTION_IN_PAGE_ERROR
                MOV ESI, OFFSET szIN_PAGE_ERROR
        .ELSEIF dwExceptionCode == EXCEPTION_INT_DIVIDE_BY_ZERO
                MOV ESI, OFFSET szINT_DIVIDE_BY_ZERO
        .ELSEIF dwExceptionCode == EXCEPTION_INT_OVERFLOW
                MOV ESI, OFFSET szINT_OVERFLOW
        .ELSEIF dwExceptionCode == EXCEPTION_PRIV_INSTRUCTION
                MOV ESI, OFFSET szPRIV_INSTRUCTION
        .ELSEIF dwExceptionCode == EXCEPTION_SINGLE_STEP
                MOV ESI, OFFSET szSINGLE_STEP
        .ELSE
                MOV ESI, OFFSET szUNKNOWN_EXCEPTION
        .ENDIF

        INVOKE        wsprintf, ADDR pBuffer, ADDR szErrorMessage, dwExceptionAddress, ESI
        INVOKE        MessageBox, NULL, ADDR pBuffer, ADDR szErrorCaption, MB_ICONERROR OR MB_OK OR MB_APPLMODAL
        INVOKE         HeapFree,hHeap,NULL,pBuffer

        ;Try to patch our way through the bad code ;)

        MOV EAX, [lpExceptionInfo]
        MOV EAX, [EAX].EXCEPTION_POINTERS.ContextRecord
        MOV esi, [EAX].CONTEXT.regEip

        ; A length disassembler could be used to determine the size of code to be patched...
        ; Now I set the instruction length to 1 (constant) because i know it will work
        ; with the "bad" opcodes in this program... (They all have one-byte instructions)

        INVOKE VirtualProtect,ESI,1,PAGE_EXECUTE_WRITECOPY,ADDR dwPreviousProtect ;#?Override the
                                                   ;READONLY attribute of the Code segment

      MOV byte ptr [ESI], 090h ;#3Patch the bad instruction with the NOP opcode
        ;INC ESI ;INC EIP (NOT REALLY NECESSARY, SINCE WE PATCH THE BAD INSTRUCTIONS...)
        MOV EAX, [lpExceptionInfo]
        MOV EAX, [EAX].EXCEPTION_POINTERS.ContextRecord
        MOV [EAX].CONTEXT.regEip,ESI
        POPAD
        MOV EAX,-1 ;#5 Reload the context record into the processor and continue execution
                 ; from the eip given in the context.
    RET

FinalExceptionHandler ENDP

;--------------------------------------------------------------------------= -------------------------------------------
; Safe Offset for PTEH
;--------------------------------------------------------------------------= -------------------------------------------
SafeOffset:
        INVOKE MessageBox, NULL, ADDR szPTEHMessage, ADDR szPTEHCaption,MB_OK
        jmp @UninstallPerThreadSEH

end EntryPoint

;